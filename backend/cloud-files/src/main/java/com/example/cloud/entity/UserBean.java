package com.example.cloud.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.persistence.*;
import java.util.List;

@Data
@Table(name = "user")
@Entity
@TableName("user")
public class UserBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(columnDefinition = "bigint(20)")
    @TableId(type = IdType.AUTO)
    private Long userId;

    @Column(columnDefinition = "varchar(30)")
    private String username;

    @Column(columnDefinition = "varchar(35)")
    private String password;

    @Column(columnDefinition = "varchar(15)")
    private String telephone;

    @Column(columnDefinition = "varchar(100)")
    private String email;

    @Column(columnDefinition = "varchar(3)")
    private String sex;

    @Column(columnDefinition = "varchar(30)")
    private String birthday;

    @Column(name = "salt", columnDefinition = "varchar(20)")
    private String salt;//加密密码的盐
    //private byte state;//用户状态,0:创建未认证（比如没有激活，没有输入验证码等等）--等待验证的用户 , 1:正常状态,2：用户被锁定.

    @Column(columnDefinition = "varchar(100)")
    private String imageUrl;

    @Column(columnDefinition = "varchar(30)")
    private String registerTime;

    /**
     * 验证码
     */
    @Transient
    @TableField(exist = false)
    private String verificationCode;

    @Transient
    @TableField(exist = false)
    private String token;

    @Transient
    @TableField(exist = false)
    private String viewDomain;

    /**
     * 角色列表
     */
    @ManyToMany(fetch = FetchType.EAGER)//立即从数据库中进行加载数据
    @JoinTable(name = "user_role",
            joinColumns = {@JoinColumn(name = "userId")},
            inverseJoinColumns = {@JoinColumn(name = "roleId")})
    @TableField(exist = false)
    private List<RoleBean> roleList;// 一个用户具有多个角色

}
