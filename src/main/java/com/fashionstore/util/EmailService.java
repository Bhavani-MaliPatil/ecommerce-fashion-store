package com.fashionstore.util;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class EmailService {

    // Read from environment variables (set in Railway)
    private static final String RESEND_API_KEY = System.getenv("RESEND_API_KEY");
    private static final String SENDER_EMAIL   = System.getenv("SENDER_EMAIL") != null 
                                                 ? System.getenv("SENDER_EMAIL") 
                                                 : "onboarding@resend.dev";

    /**
      * Sends a 6-digit OTP to the given email address via Resend HTTP API.
      *
      * @param toEmail   recipient email
      * @param otp       6-digit OTP string
      * @return true if email sent successfully, false otherwise
      */
    public static boolean sendOtpEmail(String toEmail, String otp) {

        if (RESEND_API_KEY == null || RESEND_API_KEY.trim().isEmpty()) {
            System.err.println("[EmailService] RESEND_API_KEY env var is not set!");
            System.out.println("[EmailService] [DEVELOPMENT FALLBACK] OTP Code is: " + otp);
            return false;
        }

        try {
            String htmlBody = buildEmailHtml(otp);
            
            // Construct JSON payload
            // Resend API expects: { "from": "...", "to": ["..."], "subject": "...", "html": "..." }
            // We use simple string concatenation to avoid external JSON dependency
            String jsonPayload = "{"
                    + "\"from\":\"" + SENDER_EMAIL + "\","
                    + "\"to\":[\"" + toEmail + "\"],"
                    + "\"subject\":\"Your FashionStore Password Reset OTP\","
                    + "\"html\":\"" + htmlBody.replace("\"", "\\\"").replace("\n", "").replace("\r", "") + "\""
                    + "}";

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://api.resend.com/emails"))
                    .header("Authorization", "Bearer " + RESEND_API_KEY)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200 || response.statusCode() == 201) {
                System.out.println("[EmailService] OTP email sent successfully via Resend API to: " + toEmail);
                return true;
            } else {
                System.err.println("[EmailService] Resend API returned error status: " + response.statusCode());
                System.err.println("[EmailService] Response body: " + response.body());
                return false;
            }

        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send OTP email via Resend API: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    private static String buildEmailHtml(String otp) {
        return "<!DOCTYPE html>" +
               "<html><body style='font-family:Arial,sans-serif; background:#f5f5f5; padding:20px;'>" +
               "<div style='max-width:480px; margin:auto; background:#fff; border-radius:12px;" +
               "     padding:40px; box-shadow:0 4px 20px rgba(0,0,0,0.1);'>" +
               "  <h2 style='color:#1a1a1a; margin-bottom:8px;'>Password Reset</h2>" +
               "  <p style='color:#555; margin-bottom:24px;'>Use the OTP below to reset your FashionStore password." +
               "     It expires in <strong>10 minutes</strong>.</p>" +
               "  <div style='background:#f0f0f0; border-radius:8px; padding:24px; text-align:center;" +
               "       letter-spacing:8px; font-size:32px; font-weight:bold; color:#1a1a1a;'>" +
               otp +
               "  </div>" +
               "  <p style='color:#888; font-size:12px; margin-top:24px;'>" +
               "     If you did not request this, please ignore this email. Your password will not change." +
               "  </p>" +
               "</div></body></html>";
    }
}
