#!/bin/bash
sudo hostnamectl set-hostname ${hostname}

${password_bootstrap}

${httpd_bootstrap}