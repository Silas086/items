package com.wc.controller;

import com.wc.entity.UserInfo;
import com.wc.pojo.Result;
import com.wc.service.UserInfoService;
import com.wc.utils.JwtUtil;
import com.wc.utils.PasswordUtil;
import com.wc.utils.ThreadLocalUtil;
import com.wc.vo.AuthUserInfoVO;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
@Validated
public class AuthUserController {

    private final UserInfoService userInfoService;

    public AuthUserController(UserInfoService userInfoService) {
        this.userInfoService = userInfoService;
    }

    @PostMapping("/register")
    public Result<Void> register(String username,
                                 String password,
                                 String nickname,
                                 String email) {
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            return Result.error("用户名和密码不能为空");
        }

        UserInfo existing = userInfoService.getUserByUsername(username.trim());
        if (existing != null) {
            return Result.error("用户名已被占用!");
        }

        userInfoService.registerUser(
                username.trim(),
                PasswordUtil.hash(password.trim()),
                StringUtils.hasText(nickname) ? nickname.trim() : username.trim(),
                StringUtils.hasText(email) ? email.trim() : null
        );
        return Result.success();
    }

    @PostMapping("/login")
    public Result<String> login(String username, String password) {
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            return Result.error("用户名和密码不能为空");
        }

        UserInfo loginUser = userInfoService.getUserByUsername(username.trim());
        if (loginUser == null) {
            return Result.error("用户名未注册!");
        }

        if (!PasswordUtil.check(password.trim(), loginUser.getPassword())) {
            return Result.error("用户密码错误！");
        }

        // --- 平滑安全升级：如果用户使用的还是老的 MD5 哈希，帮其升级替换为 BCrypt 保存 ---
        if (PasswordUtil.needsUpgrade(loginUser.getPassword())) {
            String newHash = PasswordUtil.hash(password.trim());
            loginUser.setPassword(newHash);
            try {
                userInfoService.updateById(loginUser); 
            } catch (Exception ex) {
                // ignore
            }
        }

        Map<String, Object> claims = new HashMap<>();
        claims.put("id", loginUser.getId());
        claims.put("username", loginUser.getUsername());
        String token = JwtUtil.genToken(claims);
        return Result.success(token);
    }

    @GetMapping("/userInfo")
    public Result<AuthUserInfoVO> userInfo(@RequestHeader("Authorization") String authorization) {
        Map<String, Object> claims = ThreadLocalUtil.get();
        if (claims == null) {
            claims = JwtUtil.parseToken(authorization);
        }
        String username = (String) claims.get("username");
        UserInfo userInfo = userInfoService.getUserByUsername(username);
        if (userInfo == null) {
            return Result.error("用户不存在");
        }

        AuthUserInfoVO response = new AuthUserInfoVO();
        response.setId(userInfo.getId());
        response.setUsername(userInfo.getUsername());
        response.setNickname(userInfo.getNick());
        response.setEmail(userInfo.getEmail());
        if (userInfo.getUserImageDO() != null) {
            response.setUserPic(userInfo.getUserImageDO().getObject());
        }
        return Result.success(response);
    }
}
