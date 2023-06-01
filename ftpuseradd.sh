#!/bin/bash
apt-get install csvtool sudo && apt update -y

csv_file="userlist.csv"
last_modified_file=".last_modified"

# Vérifier si le fichier CSV a été modifié depuis la dernière exécution du script
#if [[ -e "$last_modified_file" && "$csv_file" -ot "$last_modified_file" ]]; then
#  echo "Le fichier CSV n'a pas été modifié depuis la dernière exécution."
#  exit 0
#fi

# Mettre à jour la date de modification du fichier
touch "$last_modified_file"

# Lire le fichier CSV et créer ou mettre à jour les utilisateurs correspondants
csvtool -t ',' -u ' ' cat "$csv_file" | tail -n +2 | while IFS=" " read -r id first_name last_name password role; do
  # Ignorer les lignes vides
  if [[ -z "$id" ]]; then
    continue
  fi

  # Supprimer les espaces supplémentaires dans les noms
  first_name=$(echo "$first_name" | sed 's/ //g')
  last_name=$(echo "$last_name" | sed 's/ //g')

  # Créer l'utilisateur avec le nom d'utilisateur spécifié
  if [[ -z "$last_name" ]]; then
    username="$first_name"
  else
    username="${last_name}_${first_name}"
  fi

  # Vérifier si l'utilisateur est administrateur
  if [[ "$role" == "Admin" ]]; then
    echo "$username ajouté au groupe Sudo en tant qu'Admin"
    # Vérifier si l'utilisateur est déjà membre du groupe sudo
    if ! getent group sudo | grep -q "\b$username\b"; then
      # Ajouter l'utilisateur au groupe sudo
      sudo useradd -m --shell /bin/false -c "$first_name $last_name" -u "$id" "$username"
      echo "$username:$password" | sudo chpasswd
      sudo usermod -aG sudo "$username"
      echo "L'utilisateur $username a été créé avec succès et ajouté au groupe sudo."
    else
      # Mettre à jour les informations de l'utilisateur existant
      sudo usermod -c "$first_name $last_name" -u "$id" "$username"
      echo "Les informations de l'utilisateur $username ont été mises à jour."
    fi
  else
    # Vérifier si l'utilisateur existe déjà
    if id "$username" >/dev/null 2>&1; then
      echo "L'utilisateur $username existe déjà."
      # Vérifier si l'utilisateur doit être rétrogradé de l'administrateur à l'utilisateur
      if getent group sudo | grep -q "\b$username\b"; then
        # Supprimer l'utilisateur du groupe sudo
        sudo deluser "$username" sudo
        echo "Les droits administrateur ont été retirés à l'utilisateur $username."
      fi
    else
      sudo useradd -m --shell /bin/false -c "$first_name $last_name" -u "$id" "$username"
      echo "$username:$password" | sudo chpasswd
      echo "L'utilisateur $username a été créé avec succès."
    fi
  fi

done