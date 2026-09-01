import { withSupabase } from "@supabase/server"

export default {
  fetch: withSupabase({ auth: "user" }, async (_req, ctx) => {
    // ctx.supabase is initialized and scoped based on the user JWT
    const { data, error } = await ctx.supabase.from("restaurants").select("*")
    
    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      })
    }

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    })
  }),
}
