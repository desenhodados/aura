# Aura (Flutter)

Ficha de avaliação inicial de medicina estética, consentimento de imagens com assinatura, fotografias e PDF.

## Arrancar
```
flutter pub get
flutter run
```
Não há geração de código (build_runner). Funciona em Android, iOS e web.

## Dados
Tudo fica guardado localmente e **encriptado (AES)**: registos, fotografias e assinaturas.
A chave de encriptação fica no Keychain (iOS) / Keystore (Android).

## Permissões (câmara e fotos)
**iOS** - em `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>A Aura usa a câmara para fotografar o paciente (com consentimento).</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>A Aura pode importar fotografias da galeria para a ficha do paciente.</string>
```
**Android** - o `image_picker` não exige configuração extra.

## Consentimento
Edita `lib/features/consent/consent_texto.dart`: preenche `clinicaResponsavel` e, se mudares o texto, sobe `versaoConsentimento`. O texto deve ser revisto por um jurista/encarregado de proteção de dados.

## Documentos
- **Modelos** (ícone de documentos no topo da lista): consentimentos informados e recomendações pós-tratamento. Podem ser editados, apagados e criados novos. Usa {nome}, {primeiro_nome} e {data} nos textos.
- **Assinatura da médica**: guardada uma vez (menu dos consentimentos) e usada em todos os consentimentos novos.
- Recomendações: WhatsApp e e-mail abrem com a mensagem pronta; para enviar PDF como anexo usa "Gerar PDF" e "Partilhar".
