package com.mih.webauthn.demo.domain;

import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface MyUserRepo extends CrudRepository<MyUser, Long> {
    Optional<MyUser> findByUsername(String username);
}
