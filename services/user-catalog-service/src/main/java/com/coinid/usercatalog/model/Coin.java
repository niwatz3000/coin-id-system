package com.coinid.usercatalog.model;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "coins_catalog")
public class Coin {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(name = "coin_name", nullable = false)
    private String coinName;

    private String country;

    @Column(name = "year_minted")
    private Integer yearMinted;

    private String denomination;
    private String material;

    @Column(name = "mint_mark")
    private String mintMark;

    private String rarity;
    private String description;

    @Column(name = "reference_image_url")
    private String referenceImageUrl;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;

    // --- Getters & setters ---

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public String getCoinName() { return coinName; }
    public void setCoinName(String coinName) { this.coinName = coinName; }

    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }

    public Integer getYearMinted() { return yearMinted; }
    public void setYearMinted(Integer yearMinted) { this.yearMinted = yearMinted; }

    public String getDenomination() { return denomination; }
    public void setDenomination(String denomination) { this.denomination = denomination; }

    public String getMaterial() { return material; }
    public void setMaterial(String material) { this.material = material; }

    public String getMintMark() { return mintMark; }
    public void setMintMark(String mintMark) { this.mintMark = mintMark; }

    public String getRarity() { return rarity; }
    public void setRarity(String rarity) { this.rarity = rarity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getReferenceImageUrl() { return referenceImageUrl; }
    public void setReferenceImageUrl(String referenceImageUrl) { this.referenceImageUrl = referenceImageUrl; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
