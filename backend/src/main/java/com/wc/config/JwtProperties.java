package com.wc.config;

import com.wc.utils.JwtUtil;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtProperties {

    @Value("${jwt.secret:uYf4p9v!X2$kL8mQwE7zJ1#bN0cXaR5tG}")
    private String secret;

    @PostConstruct
    public void init() {
        JwtUtil.setKey(secret);
    }
}
