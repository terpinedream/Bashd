# Setting Up Bashd 

## Installation
##### **1. Clone the repository:**
```
git clone https://github.com/terpinedream/Bashd
```

##### **2. Copy scripts to shell path:**
```
# Usually /usr/bin or /usr/local/bin -> needs sudo
sudo cp -r ~/Bashd/scripts/ /usr/local/bin
```

##### **3. Navigate to shell path and give permissions:**
```
# or /usr/bin
# Ensure files aren't nested e.g. files in /bin/ not /bin/scripts/
cd /usr/local/bin && ls

# Give permissions
chmod +x *

chmod +x /path/to/Bashd/bashd-init.sh
```
##### **4. Navigate to ~/.bashrc:**
```
# edit .bashrc
nano ~/.bashrc 

# Add this line to allow crush to run as a function 
# Replace path with actual path to bashd-init.sh 
source /path/to/Bashd/bashd-init.sh

# Ensure proper path
type crush 

# Should return this
crush is a function
crush () 
{ 
    eval "$(command crush)"
}
```

##### **5. Run bashd to see full list of commands:**
```
bashd
```
