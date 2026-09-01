import { withSupabase } from "@supabase/server"

export default {
  fetch: withSupabase({ auth: "none" }, async (req, ctx) => {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { "Content-Type": "application/json" },
      })
    }

    try {
      const body = await req.json()
      const { name, admin, email, password, plan, status } = body

      if (!name || !admin || !email || !password || !plan || !status) {
        return new Response(JSON.stringify({ error: "Missing required fields" }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        })
      }

      const cleanEmail = email.trim().toLowerCase()

      // 1. Create Auth User using Admin Auth client (bypasses confirmation emails & rate limits)
      const { data: userData, error: authError } = await ctx.supabaseAdmin.auth.admin.createUser({
        email: cleanEmail,
        password: password,
        email_confirm: true, // Automatically verify the user's email
      })

      if (authError) {
        return new Response(JSON.stringify({ error: `Auth registration failed: ${authError.message}` }), {
          status: 400,
          headers: { "Content-Type": "application/json" },
        })
      }

      const userId = userData.user.id
      const restId = crypto.randomUUID()

      // 2. Create Restaurant row using RLS-bypassing admin client
      const { error: restError } = await ctx.supabaseAdmin.from("restaurants").insert({
        id: restId,
        name: name,
        currency: "PKR",
        currency_symbol: "Rs. ",
        tax_percentage: 18.0,
        plan_name: plan,
        status: status,
        kitchen_bypass: false,
      })

      if (restError) {
        // Rollback created user if db insert fails to keep auth clean
        await ctx.supabaseAdmin.auth.admin.deleteUser(userId)
        return new Response(JSON.stringify({ error: `Database error (restaurants): ${restError.message}` }), {
          status: 500,
          headers: { "Content-Type": "application/json" },
        })
      }

      // 3. Create User Profile row using RLS-bypassing admin client
      const { error: userError } = await ctx.supabaseAdmin.from("users").upsert({
        id: userId,
        name: admin,
        email: cleanEmail,
        role_id: 2, // Admin
        restaurant_id: restId,
      })

      if (userError) {
        // Rollback
        await ctx.supabaseAdmin.auth.admin.deleteUser(userId)
        await ctx.supabaseAdmin.from("restaurants").delete().eq("id", restId)
        return new Response(JSON.stringify({ error: `Database error (users): ${userError.message}` }), {
          status: 500,
          headers: { "Content-Type": "application/json" },
        })
      }

      return new Response(JSON.stringify({ success: true, restaurantId: restId, userId: userId }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      })
    } catch (e) {
      return new Response(JSON.stringify({ error: `Server error: ${e.toString()}` }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      })
    }
  }),
}
