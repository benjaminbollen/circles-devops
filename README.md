# Circles DevOps Guide

This README provides instructions on setting up a Conda (or Mamba) environment for Ansible and installing the necessary dependencies to manage and automate your infrastructure with our DevOps repository.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Conda or Miniconda (lightweight Conda)
- Git (Version control system)

If you prefer to use Mamba, it can be installed on top of Conda/Miniconda for faster package resolution and installation.

## Setting Up Conda/Mamba Environment

1. **Create a New Environment**

   Create a new Conda environment specifically for your DevOps operations.

   ```sh
   conda create --name devops python=3.9
   ```

   This command creates a new environment named `devops` with Python 3.8. You can choose a different name or Python version if required.

2. **Activate the Environment**

   Activate the new environment using the following command:

   ```sh
   conda activate devops
   ```

3. **(Optional) Install Mamba**

   If you prefer to use Mamba, install it within the Conda environment:

   ```sh
   conda install mamba -c conda-forge
   ```

## Installing Ansible

With the environment activated, you can install Ansible. If you're using Mamba, you can replace `conda` with `mamba` in the command below for faster installation.

```sh
conda install -c conda-forge ansible
```

## Additional Dependencies

If the repository includes an Ansible requirements file (`requirements.yml`), you can install the required Ansible collections and roles using:

```sh
ansible-galaxy install -r requirements.yml
```

## Configuring Ansible

1. **Inventory File**

   Set up an inventory file with details about the hosts. This can be in INI or YAML format (`inventory.ini` or `inventory.yml`).

2. **Ansible Configuration File**

   An `ansible.cfg` in your project directory can be used to customize Ansible's behavior.

3. **SSH Keys**

   Make sure you have SSH keys configured for passwordless access to your target servers.

## Running Ansible Playbooks

To run an Ansible playbook with the active environment, execute:

```sh
ansible-playbook -i inventory.ini playbook.yml
```

Replace `playbook.yml` with the name of your playbook file.

## Exiting the Conda/Mamba Environment

When finished, deactivate the environment by running:

```sh
conda deactivate
```

This command will revert to the base Conda environment or your system’s default Python interpreter.
