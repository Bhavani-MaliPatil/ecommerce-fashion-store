<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
</head>
<body>

<div class="auth-wrapper">

  <!-- ── Left: Form Panel ── -->
  <div class="auth-panel auth-panel--form">
    <div class="auth-form-container">

      <p class="auth-subheading" style="margin-bottom:32px; letter-spacing:3px;">
        FASHION<span style="color:var(--gold);">STORE</span>
      </p>

      <% if (request.getAttribute("success") != null) { %>

        <!-- Success state -->
        <div style="text-align:center; padding: 24px 0;">
          <div style="font-size:48px; margin-bottom:16px;">✓</div>
          <h1 class="auth-heading" style="font-size:32px;">Done!</h1>
          <p class="auth-subheading" style="margin-bottom:32px;">
            Your password has been reset successfully.
          </p>
          <a href="${pageContext.request.contextPath}/user?action=login" class="btn-primary" style="display:block; text-align:center;">
            Sign In Now
          </a>
        </div>

      <% } else { %>

        <h1 class="auth-heading">Reset<br>Password.</h1>
        <p class="auth-subheading">
          Remember it?
          <a href="${pageContext.request.contextPath}/user?action=login">Sign in instead</a>
        </p>

        <!-- Error alert -->
        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-error">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
          <input type="hidden" name="action" value="forgotPassword">

          <div class="form-group">
            <label for="email">Email address</label>
            <input
              type="email"
              id="email"
              name="email"
              placeholder="you@example.com"
              value="${emailValue}"
              required
              autocomplete="email"
            >
          </div>

          <div class="form-group">
            <label for="pincode">Your Pincode <span style="color:var(--muted); font-size:11px;">(used during registration)</span></label>
            <input
              type="text"
              id="pincode"
              name="pincode"
              placeholder="e.g. 560001"
              required
            >
          </div>

          <div class="form-group">
            <label for="newPassword">New Password</label>
            <input
              type="password"
              id="newPassword"
              name="newPassword"
              placeholder="Min. 6 characters"
              required
              autocomplete="new-password"
            >
          </div>

          <button type="submit" class="btn-primary">Reset Password</button>
        </form>

      <% } %>

    </div>
  </div>

  <!-- ── Right: Visual Panel ── -->
  <div class="auth-panel auth-panel--visual">
    <div class="visual-content">
      <div class="visual-logo">FASHION<span>.</span></div>
      <p class="visual-tagline">Curated Style &nbsp;·&nbsp; Premium Quality</p>

      <div class="visual-accent"></div>

      <div class="visual-lines">
        <div class="visual-line">Secure</div>
        <div class="visual-line active">Private</div>
        <div class="visual-line">Protected</div>
      </div>
    </div>
  </div>

</div>

<script>
  const lines = document.querySelectorAll('.visual-line');
  let current = 1;
  setInterval(() => {
    lines.forEach(l => l.classList.remove('active'));
    current = (current + 1) % lines.length;
    lines[current].classList.add('active');
  }, 2000);
</script>

</body>
</html>
