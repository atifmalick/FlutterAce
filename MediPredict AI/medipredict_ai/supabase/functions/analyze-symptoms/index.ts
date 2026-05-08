// Supabase Edge Function: analyze-symptoms
// Deploy with: supabase functions deploy analyze-symptoms
//
// This function uses the Gemini API to analyze user symptoms
// and return a structured risk assessment.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { symptoms } = await req.json();

    if (!symptoms || typeof symptoms !== "string") {
      return new Response(
        JSON.stringify({ error: "Missing or invalid 'symptoms' field" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const prompt = `You are a medical triage AI assistant. Analyze the following symptoms and provide a risk assessment.

SYMPTOMS: "${symptoms}"

Respond ONLY with valid JSON in this exact format (no markdown, no code blocks):
{
  "risk_level": "Low" or "Medium" or "High",
  "risk_score": <integer 1-10>,
  "possible_conditions": ["condition1", "condition2", "condition3"],
  "recommendations": ["recommendation1", "recommendation2", "recommendation3"],
  "disclaimer": "This is an AI-generated assessment and not a medical diagnosis. Please consult a healthcare professional for proper evaluation."
}`;

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.3,
            maxOutputTokens: 500,
          },
        }),
      }
    );

    const geminiData = await geminiResponse.json();
    const textContent =
      geminiData?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    // Parse the JSON from Gemini's response
    const jsonMatch = textContent.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error("Failed to parse Gemini response as JSON");
    }

    const result = JSON.parse(jsonMatch[0]);

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        risk_level: "Low",
        risk_score: 1,
        possible_conditions: ["Unable to analyze - please try again"],
        recommendations: ["If symptoms are severe, seek immediate medical attention"],
        disclaimer: "Analysis failed. This is not a medical diagnosis.",
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
