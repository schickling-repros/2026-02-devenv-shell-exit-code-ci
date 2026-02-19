{ pkgs, ... }:
{
  tasks."test:fail".exec = ''
    echo intentional-failure
    exit 1
  '';
}
