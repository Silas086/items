package com.wc.utils;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    private PasswordUtil() {
    }

    /**
     * 对密码进行 BCrypt 哈希加密
     *
     * @param plainPassword 明文密码
     * @return 60 位的 BCrypt 密文
     */
    public static String hash(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }

    /**
     * 校验密码是否正确（兼容老的 MD5 密码体系）
     * 如果数据库存的是 32 位 MD5 密文，走老的 MD5 校验即可；
     * 其他情况走正式的 BCrypt 校验。
     *
     * @param plainPassword 明文密码
     * @param hashedPassword 存放在数据库里的哈希密码
     * @return 是否校验通过
     */
    public static boolean check(String plainPassword, String hashedPassword) {
        if (hashedPassword == null || hashedPassword.isEmpty()) {
            return false;
        }
        // 如果是历史遗留的 32 位 MD5
        if (hashedPassword.length() == 32) {
            return Md5Util.getMD5String(plainPassword).equals(hashedPassword);
        }
        // 走更安全的 BCrypt 校验
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * 判断是否是老的 MD5 密码，需要做无缝迁移
     *
     * @param hashedPassword 存放在数据库里的哈希密码
     * @return true 代表这是一条待升级的 MD5 数据
     */
    public static boolean needsUpgrade(String hashedPassword) {
        return hashedPassword != null && hashedPassword.length() == 32;
    }
}
