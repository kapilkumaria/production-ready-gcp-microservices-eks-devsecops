// src/middleware/user.js

export default function userMiddleware(req, res, next) {
  const cookies = req.cookies || {};      // ← prevent crash
  let userId = cookies.user_id;

  if (!userId) {
    userId = Math.random().toString(36).slice(2);

    res.cookie("user_id", userId, {
      httpOnly: false,
      sameSite: "lax",
      expires: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });
  }

  req.userId = userId;
  next();
}
