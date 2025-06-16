# 📍 CheckPoint

Aplicativo mobile desenvolvido em Flutter para registrar, compartilhar e acompanhar conquistas relacionadas a visitas nos lugares da PUCMINAS. Este projeto foi criado como parte do **Projeto Integrado I - Engenharia de Computação (PUC Minas - Coração Eucarístico)**.

---

## 📱 Sobre o App

O **CheckPoint** é um app que permite aos usuários:
- Registrar lugares importantes com descrição e lcalização
- Visualizar sua linha do tempo de conquistas
- Editar seu perfil e acompanhar conquistas desbloqueadas
- Navegar facilmente com barra inferior fixa
- Explorar um carrossel de introdução ao abrir o app pela primeira vez

---

## 🚀 Tecnologias utilizadas

- **Flutter** — Framework principal
- **Dart** — Linguagem de programação
- **Firebase Auth & Firestore** — Autenticação e banco de dados em nuvem
- **Mapbox** — Exibição e marcação de locais no mapa
- **Geolocator / Permission Handler** — Acesso à localização
- **Plataformas:** Android e iOS

## ⚙️ Como rodar o projeto

1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/checkpoint.git
cd checkpoint/checkpointapp
```
   
2. Va para a pasta chechpoink app instale as dependências e execute o aplicativo:
```bash
flutter pub get
flutter run
```

---

## 🗂️ Estrutura do Repositório

```bash


Respositorio:.
│   CheckPoint.png	// Logo do aplicativo
│   gitignore
│   README.md
│
└───checkpointapp	// Pasta de Desenvolvimento
    │
    ├───assets		// Imagems do aplictivo
    │
    │       album.png
    │       CheckPoint.png
    │       Chiquinha.jpg
    │       circulos.png
    │       comida-e-restaurante.png
    │       compartilhar.png
    │       coracao.png
    │       documento.png
    │       fb-icon.png
    │       fotos.png
    │       login-icon.png
    │       mapa-de-viagem.png
    │       map_marker.png
    │       medalha.png
    │       profile-picture.png
    │       profile-picture2.png
    │       reset-password-icon.png
    │       voar.png	
    │
    ├───lib		// Codigo pricipal do projeto em DART
    │   │
    │   │   Configuracoes.dart
    │   │   firebase_options.dart
    │   │   main.dart
    │   │   root.dart              // Pagina pricipal que chama as demais telas
    │   │   sobre_o_app.dart
    │   │
    │   ├───BancoDeDados
    │   │       auth_service.dart
    │   │       Localizacoes.dart
    │   │       user_firestore_service.dart
    │   │       user_preferences_services.dart
    │   │
    │   ├───login
    │   │       login_page.dart
    │   │       reset_password_page.dart
    │   │       signup_page.dart
    │   │       start_page.dart
    │   │
    │   ├───Mapa
    │   │       location_bottom_sheet.dart
    │   │       map.dart
    │   │       search_place.dart
    │   │
    │   ├───Profile
    │   │       configuracoes_perfil.dart
    │   │       Conquistas.dart
    │   │       grade_de_fotos.dart
    │   │       imagem_ampliada.dart
    │   │       quadrados_das_fotos.dart
    │   │       tela_perfil.dart
    │   │
    │   └───timeline
    │           pagina_comentarios.dart
    │           postcard.dart
    │           timeline.dart
    │
    ├───ios 			// Programa para IOS
    │
    ├───android 		// Programa para android
    │
    └─── pubspec.yaml 		// Arquivo de configurações pricipal
	

```
---

## 🧪 Funcionalidades principais

- [x] Cadastro, login e restore de senha de usuário  (Firebase)
- [x] Timeline com postagens
- [x] Perfil do usuário com edição de dados pessoais
- [x] Conquistas visuais desbloqueáveis
- [x] Mapa com pontos salvos
- [x] Tela "Sobre o App" com carrossel
- [x] Navegação intuitiva por `BottomNavigationBar`

---

## 📸 Capturas de tela

*****

