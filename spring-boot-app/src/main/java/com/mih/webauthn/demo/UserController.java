package com.mih.webauthn.demo;

import com.mih.webauthn.demo.domain.MyUser;
import com.mih.webauthn.demo.domain.MyUserRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {

    @Autowired
    MyUserRepo userRepo;

    @GetMapping("/api/whoami")
    public MyUser whoami(@AuthenticationPrincipal UserDetails user) {
        return userRepo.findByUsername(user.getUsername())
                .orElseThrow();
    }
}
