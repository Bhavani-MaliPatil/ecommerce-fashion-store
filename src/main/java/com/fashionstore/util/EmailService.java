package com.fashionstore.util;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.util.Properties;

public class EmailService {

    // Read from environment variables (set in Railway)
    private static final String SMTP_EMAIL    = System.getenv("SMTP_EMAIL");
    private static final String SMTP_PASSWORD = System.getenv("SMTP_PASSWORD");

    private static final String SMTP_HOST = System.getenv("SMTP_HOST") != null ? System.getenv("SMTP_HOST") : "smtp.gmail.com";
    private static final int    SMTP_PORT = System.getenv("SMTP_PORT") != null ? Integer.parseInt(System.getenv("SMTP_PORT")) : 587;

    /**
     * Sends a 6-digit OTP to the given email address.
     *
     * @param toEmail   recipient email
     * @param otp       6-digit OTP string
     * @return true if email sent successfully, false otherwise
     */
    public static boolean sendOtpEmail(String toEmail, String otp) {

        if (SMTP_EMAIL == null || SMTP_PASSWORD == null) {
            System.err.println("[EmailService] SMTP credentials missing. SMTP_EMAIL=" + (SMTP_EMAIL == null ? "null" : "set") + ", SMTP_PASSWORD=" + (SMTP_PASSWORD == null ? "null" : "set"));
            System.err.println("[EmailService] Ensure SMTP_EMAIL and SMTP_PASSWORD env vars are configured in Railway.");
            return false;
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_EMAIL, SMTP_PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_EMAIL, "FashionStore"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Your FashionStore Password Reset OTP");

            // HTML email body
            String htmlBody = buildEmailHtml(otp);
            message.setContent(htmlBody, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("[EmailService] OTP email sent to: " + toEmail);
            return true;

        } catch (Exception e) {
            System.err.println("[EmailService] Failed to send OTP email: " + e.getMessage());
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
