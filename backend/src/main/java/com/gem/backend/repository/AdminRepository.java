package com.gem.backend.repository;

import com.gem.backend.model.Admin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdminRepository extends JpaRepository<Admin, Integer> {

    boolean existsByPessoa_Cpf(String cpf);
}
