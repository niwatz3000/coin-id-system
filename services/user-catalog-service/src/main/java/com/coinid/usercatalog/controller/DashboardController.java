package com.coinid.usercatalog.controller;

import com.coinid.usercatalog.repository.CoinRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final CoinRepository coinRepository;
    private final JdbcTemplate jdbcTemplate;

    public DashboardController(CoinRepository coinRepository, JdbcTemplate jdbcTemplate) {
        this.coinRepository = coinRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/summary")
    public Map<String, Object> summary() {
        long totalCoins = coinRepository.count();
        Long totalRequests = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM matching_requests", Long.class);
        Long matchedRequests = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM matching_requests WHERE status = 'MATCHED'", Long.class);
        Long pendingRequests = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM matching_requests WHERE status IN ('PENDING','PROCESSING')", Long.class);

        return Map.of(
                "totalCoinsInCatalog", totalCoins,
                "totalMatchingRequests", totalRequests == null ? 0 : totalRequests,
                "matchedRequests", matchedRequests == null ? 0 : matchedRequests,
                "pendingRequests", pendingRequests == null ? 0 : pendingRequests
        );
    }
}
