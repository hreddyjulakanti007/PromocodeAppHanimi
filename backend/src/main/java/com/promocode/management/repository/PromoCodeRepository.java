package com.promocode.management.repository;

import com.promocode.management.model.PromoCode;
import com.promocode.management.model.PromoCodeStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PromoCodeRepository extends JpaRepository<PromoCode, Long> {

    List<PromoCode> findByTenantId(String tenantId);

    Optional<PromoCode> findByIdAndTenantId(Long id, String tenantId);

    Optional<PromoCode> findByCodeAndTenantId(String code, String tenantId);

    @Query("SELECT p FROM PromoCode p WHERE p.tenantId = :tenantId " +
            "AND (:code IS NULL OR p.code LIKE CONCAT('%', :code, '%')) " +
            "AND (:status IS NULL OR p.status = :status) " +
            "AND (CAST(:startDate AS timestamp) IS NULL OR p.createdAt >= :startDate) " +
            "AND (CAST(:endDate AS timestamp) IS NULL OR p.createdAt <= :endDate)")
    List<PromoCode> findByFilters(
            @Param("tenantId") String tenantId,
            @Param("code") String code,
            @Param("status") PromoCodeStatus status,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);
}
