package com.fashionstore.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Database URL
    private static final String URL;

    // Database credentials
    private static final String USER;
    private static final String PASSWORD;

    static {
        String envUrl = System.getenv("DB_URL");
        if (envUrl != null && !envUrl.isEmpty()) {
            URL = envUrl;
        } else {
            String host = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";
            String port = System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";
            String name = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "fashion_store";
            URL = "jdbc:mysql://" + host + ":" + port + "/" + name + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        }
        USER = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        PASSWORD = System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "Bhava@9845";
    }

    // Get Connection Method
    public static Connection getConnection() {
        Connection connection = null;

        try {
            // Load MySQL Driver (optional for newer versions, but safe)
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Establish connection
            connection = DriverManager.getConnection(URL, USER, PASSWORD);

            System.out.println("Database Connected Successfully!");

        } catch (ClassNotFoundException e) {
            System.out.println("MySQL Driver not found!");
            e.printStackTrace();

        } catch (SQLException e) {
            System.out.println("Connection Failed!");
            e.printStackTrace();
        }

        return connection;
    }
}