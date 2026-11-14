@echo off
rem Starts the Pawdian home server (web edition). Keep this window open.
cd /d "%~dp0.."
dart run bin/pawdian_server.dart %*
