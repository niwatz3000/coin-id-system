package com.coinid.usercatalog;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@SpringBootApplication
public class UserCatalogServiceApplication {

    private static String url;
    private static String username;
    private static String password;

    // จำเป็นต้องมี Getter และ Setter
    public static String getUrl() { return url; }
    public static void setUrl(String url) { UserCatalogServiceApplication.url = url; }
    
    public static String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public static String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public static void main(String[] args) {

        Logger logger = LoggerFactory.getLogger(UserCatalogServiceApplication.class);


        logger.info("=== Database Configuration Loaded ===");
        logger.info("Database URL: {}", getUrl());
        logger.info("User: {}", getUsername());
        logger.info("Password: {}", getPassword()); // หมายเหตุ: ในระบบจริงไม่ควร Log password แบบข้อความดิบ
        logger.info("====================================");

        SpringApplication.run(UserCatalogServiceApplication.class, args);
    }
}
