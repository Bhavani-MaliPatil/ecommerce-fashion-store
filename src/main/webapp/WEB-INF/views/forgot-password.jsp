<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password — FashionStore</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auth.css">
  <style>
    .otp-input {
      letter-spacing: 6px;
      font-size: 24px;
      text-align: center;
      font-weight: 700;
    }
    .alert-info {
      background: rgba(99, 179, 237, 0.12);
      border: 1px solid rgba(99, 179, 237, 0.35);
      color: #63b3ed;
      padding: 14px 18px;
      border-radius: 10px;
      margin-bottom: 22px;
      font-size: 14px;
    }
    .step-badge {
      display: inline-block;
      background: rgba(212,175,55,0.15);
      color: var(--gold, #d4af37);
      border: 1px solid rgba(212,175,55,0.35);
      border-radius: 20px;
      padding: 4px 14px;
      font-size: 11px;
      letter-spacing: 2px;
      text-transform: uppercase;
      margin-bottom: 16px;
    }
  </style>
</head>
<body>

<div class="auth-wrapper">

  <!-- ── Left: Form Panel ── -->
  <div class="auth-panel auth-panel--form">
    <div class="auth-form-container">

      <p class="auth-subheading" style="margin-bottom:32px; letter-spacing:3px;">
        FASHION<span style="color:var(--gold);">STORE</span>
      </p>

      <%-- ══════════ SUCCESS STATE ══════════ --%>
      <% if (request.getAttribute("success") != null) { %>

        <div style="text-align:center; padding: 24px 0;">
          <div style="font-size:56px; margin-bottom:16px;">✅</div>
          <h1 class="auth-heading" style="font-size:30px;">All Done!</h1>
          <p class="auth-subheading" style="margin-bottom:32px;">
            Your password has been reset. You can now sign in with your new password.
          </p>
          <a href="${pageContext.request.contextPath}/user?action=login" class="btn-primary"
             style="display:block; text-align:center;">
            Sign In Now
          </a>
        </div>

      <%-- ══════════ STEP 2: OTP + New Password ══════════ --%>
      <% } else if (Boolean.TRUE.equals(request.getAttribute("otpSent"))) { %>

        <div class="step-badge">Step 2 of 2</div>
        <h1 class="auth-heading">Enter OTP.</h1>
        <p class="auth-subheading">
          Check your inbox for the 6-digit code.
          <a href="${pageContext.request.contextPath}/user?action=forgotPassword">Wrong email?</a>
        </p>

        <% if (request.getAttribute("info") != null) { %>
          <div class="alert-info">📧 ${info}</div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-error">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
          <input type="hidden" name="action" value="forgotPassword">
          <input type="hidden" name="step"   value="2">
          <input type="hidden" name="email"  value="${emailValue}">

          <div class="form-group">
            <label for="otp">6-Digit OTP</label>
            <input
              type="text"
              id="otp"
              name="otp"
              class="otp-input"
              placeholder="______"
              maxlength="6"
              required
              autocomplete="one-time-code"
              inputmode="numeric"
              pattern="[0-9]{6}"
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

      <%-- ══════════ STEP 1: Enter Email ══════════ --%>
      <% } else { %>

        <div class="step-badge">Step 1 of 2</div>
        <h1 class="auth-heading">Forgot<br>Password?</h1>
        <p class="auth-subheading">
          Enter your email and we'll send you a one-time password.
          <a href="${pageContext.request.contextPath}/user?action=login">Back to sign in</a>
        </p>

        <% if (request.getAttribute("error") != null) { %>
          <div class="alert alert-error">${error}</div>
        <% } %>

        <form action="${pageContext.request.contextPath}/user" method="post" novalidate>
          <input type="hidden" name="action" value="forgotPassword">
          <input type="hidden" name="step"   value="1">

          <div class="form-group">
            <label for="email">Email address</label>
            <input
              type="email"
              id="email"
              name="email"
              placeholder="you@example.com"
              required
              autocomplete="email"
            >
          </div>

          <button type="submit" class="btn-primary">Send OTP →</button>
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

  // Auto-format OTP input
  const otpInput = document.getElementById('otp');
  if (otpInput) {
    otpInput.addEventListener('input', function() {
      this.value = this.value.replace(/\D/g, '').substring(0, 6);
    });
  }
</script>

</body>
</html>
