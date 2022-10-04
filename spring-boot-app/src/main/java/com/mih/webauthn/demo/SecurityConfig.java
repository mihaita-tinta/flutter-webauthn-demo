package com.mih.webauthn.demo;

import com.mih.webauthn.demo.domain.MyUser;
import com.mih.webauthn.demo.domain.MyUserRepo;
import io.github.webauthn.EnableWebAuthn;
import io.github.webauthn.config.WebAuthnConfigurer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.builders.WebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;


@Configuration
@EnableJpaRepositories
@EntityScan("com.mih.webauthn.demo")
@EnableWebAuthn
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    private static final Logger log = LoggerFactory.getLogger(SecurityConfig.class);
    @Autowired
    MyUserRepo userRepo;

    @Override
    public void configure(WebSecurity web) {

        web.ignoring().antMatchers(
                "/h2-console/**",
                "/.well-known/assetlinks.json",
                "/login.html", "/webauthn-components/**",
                "/error");

    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable()
                .authorizeRequests()
                .anyRequest().authenticated()
                .and()
                .apply(new WebAuthnConfigurer()
                        .registerSuccessHandler(newUser -> {
                            MyUser user = new MyUser();
                            user.setUsername(newUser.getUsername());
                            user.setFirstName(newUser.getFirstName());
                            user.setLastName(newUser.getLastName());
                            userRepo.save(user);
                        })
                );
    }
}
