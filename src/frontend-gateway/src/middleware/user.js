// src/middleware/user.js

export default function userMiddleware(req, res, next) {
  let userId = req.cookies?.user_id;

  // If no user_id cookie, create one
  if (!userId) {
    userId = Math.random().toString(36).substring(2, 15);

    // 7-day expiry
    const expires = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    // cookie must be readable by frontend UI → httpOnly: false
    res.cookie("user_id", userId, {
      httpOnly: false,
      sameSite: "lax",
      expires,
    });
  }

  // Attach to request for routes to use
  req.userId = userId;

  next();
}
