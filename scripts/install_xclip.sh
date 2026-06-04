if [[ "$OSTYPE" == "linux-gnu"* ]] && ! command -v xclip &> /dev/null; then
  sudo apt-get install -y xclip
fi
