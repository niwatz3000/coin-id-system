package com.coinid.usercatalog.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/analytics")
public class AnalyticsController {

    private final JdbcTemplate jdbcTemplate;

    public AnalyticsController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/most-viewed-coins")
    public List<Map<String, Object>> mostViewedCoins() {
        return jdbcTemplate.queryForList("""
                SELECT c.id, c.coin_name, SUM(v.view_count) AS total_views
                FROM user_view_stats v
                JOIN coins_catalog c ON c.id = v.coin_id
                GROUP BY c.id, c.coin_name
                ORDER BY total_views DESC
                LIMIT 10
                """);
    }

    @GetMapping("/price-trends")
    public List<Map<String, Object>> priceTrends() {
        return jdbcTemplate.queryForList("""
                SELECT coin_id, date_trunc('month', recorded_at) AS month, AVG(price) AS avg_price
                FROM price_history
                GROUP BY coin_id, month
                ORDER BY month DESC
                LIMIT 100
                """);
    }

    @GetMapping("/matching-success-rate")
    public Map<String, Object> matchingSuccessRate() {
        Map<String, Object> row = jdbcTemplate.queryForMap("""
                SELECT
                  COUNT(*) FILTER (WHERE status = 'MATCHED')::float / NULLIF(COUNT(*), 0) AS success_rate,
                  COUNT(*) AS total_requests
                FROM matching_requests
                """);
        return row;
    }
}
