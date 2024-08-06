#!/bin/bash

# Função para exibir a animação de progresso
progress_bar() {
    local duration=0.01
    local interval=0.01
    local width=50
    local i

    for i in $(seq 0 $width); do
        sleep $interval
        percentage=$((i * 100 / width))
        bar=$(printf "%${i}s" | tr ' ' '#')
        printf "\r[%-${width}s] %d%%" "$bar" "$percentage"
    done
    echo
}

branch_exists() {
  git show-ref --verify --quiet refs/heads/"$1"
}

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "############ rep: eduardobatista-ti/init-git ############"; echo "Script de atualização de repositórios e criação de Branch."; progress_bar;

PROJECT_DIR=$(pwd)

read -r -p "Desejea atualizar Branches sem criar uma nova? (s/n): " apply_stash

if [ "$apply_stash" = "s" ]; then
  echo "Atualizando Branches..."; progress_bar
  git stash
  git fetch
        if branch_exists "main"; then
            echo "Atualizando 'main'"; progress_bar
            git checkout main && git pull || { echo "Falha ao mudar para a branch 'main' ou ao realizar o pull."; exit 1; }  
          else
            echo "Branch 'main' não existe. Saindo da execução."
            exit 1
        fi
        if branch_exists "develop"; then
            echo "Atualizando 'develop'"; progress_bar
           git checkout develop && git pull || { echo "Falha ao mudar para a branch 'develop' ou ao realizar o pull."; exit 1; }
          else
            echo "Branch 'develop' não existe. Saindo da execução."
            exit 1
        fi
   git checkout "$CURRENT_BRANCH"
   git merge develop 
   git stash apply
   echo "Atualização completa. Saindo da execução."
   exit 0   

else
  echo "Partindo para processo de criação e atualização."
  progress_bar
fi


read -r -p "Você vai sair da branch atual e pode perder alterações não salvas. Deseja sair da branch atual? (s/n): " leave_branch



if [ "$leave_branch" = "s" ]; then
  echo "Saindo da branch atual..."; progress_bar
else
  echo "Operação abortada! Saindo da execução."
  exit 1
fi

if branch_exists "main"; then
  echo "Atualizando 'main'"; progress_bar
  git checkout main && git pull || { echo "Falha ao mudar para a branch 'main' ou ao realizar o pull."; exit 1; }  
else
  echo "Branch 'main' não existe. Saindo da execução."
  exit 1
fi

if branch_exists "develop"; then
  echo "Atualizando 'develop'"; progress_bar
  git checkout develop && git pull || { echo "Falha ao mudar para a branch 'develop' ou ao realizar o pull."; exit 1; }
else
  echo "Branch 'develop' não existe. Saindo da execução."
  exit 1
fi

read -r -p "Você quer criar uma nova branch a partir da develop? (s/n): " create_branch

if [ "$create_branch" = "s" ]; then
  read -r -p "Digite o nome da nova branch que você quer criar para a feature: " new_branch
  
  if branch_exists "develop"; then
    git checkout -b "$new_branch" develop || { echo "Falha ao criar a branch '$new_branch'."; exit 1; }
    progress_bar
    echo "Nova branch '$new_branch' criada com sucesso a partir de 'develop'!"
  else
    echo "Branch 'develop' não existe."
    exit 1
  fi
else
  echo "Não foi criada uma nova branch! Saindo da execução."
  git checkout "$CURRENT_BRANCH" 
fi

