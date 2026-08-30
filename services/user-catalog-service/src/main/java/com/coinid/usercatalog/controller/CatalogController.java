package com.coinid.usercatalog.controller;

import com.coinid.usercatalog.model.Coin;
import com.coinid.usercatalog.repository.CoinRepository;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/catalog")
public class CatalogController {

    private final CoinRepository coinRepository;

    public CatalogController(CoinRepository coinRepository) {
        this.coinRepository = coinRepository;
    }

    @GetMapping
    public List<Coin> listCoins() {
        return coinRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Coin> getCoin(@PathVariable UUID id) {
        return coinRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Coin createCoin(@Valid @RequestBody Coin coin) {
        coin.setCreatedAt(Instant.now());
        coin.setUpdatedAt(Instant.now());
        return coinRepository.save(coin);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Coin> updateCoin(@PathVariable UUID id, @Valid @RequestBody Coin update) {
        return coinRepository.findById(id).map(existing -> {
            existing.setCoinName(update.getCoinName());
            existing.setCountry(update.getCountry());
            existing.setYearMinted(update.getYearMinted());
            existing.setDenomination(update.getDenomination());
            existing.setMaterial(update.getMaterial());
            existing.setMintMark(update.getMintMark());
            existing.setRarity(update.getRarity());
            existing.setDescription(update.getDescription());
            existing.setReferenceImageUrl(update.getReferenceImageUrl());
            existing.setUpdatedAt(Instant.now());
            return ResponseEntity.ok(coinRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCoin(@PathVariable UUID id) {
        if (!coinRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        coinRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
