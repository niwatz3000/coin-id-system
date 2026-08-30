package com.coinid.usercatalog.repository;

import com.coinid.usercatalog.model.Coin;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CoinRepository extends JpaRepository<Coin, UUID> {
}
