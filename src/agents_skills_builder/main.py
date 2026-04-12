import os
import sys
import subprocess

def run():
    # Pass all incoming CLI arguments seamlessly to the curl | bash remote installer
    args = sys.argv[1:]
    
    cmd = [
        "bash", "-c", 
        f"curl -fsSL https://raw.githubusercontent.com/anhnt/agents_skills_builder/main/setup.sh | bash -s -- " + " ".join(args)
    ]
    
    try:
        result = subprocess.run(cmd)
        sys.exit(result.returncode)
    except KeyboardInterrupt:
        sys.exit(130)

if __name__ == "__main__":
    run()
