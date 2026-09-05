# Segurança e RGPD

## Proteções implementadas

- Validação Zod no backend, limites de tamanho nos pedidos JSON/imagem e renderização de texto sem HTML arbitrário.
- Bcrypt custo 12, limite de 72 bytes, mensagens de recuperação que não confirmam se uma conta existe e mitigação de diferença temporal no login.
- Tokens de 32 bytes aleatórios, guardados por hash, utilização única, 24h para verificação e 30min para recuperação. Redefinir a palavra-passe revoga sessões anteriores.
- Sessões Auth.js de uma hora, cookies HttpOnly/SameSite e Secure em HTTPS; cada acesso privado consulta role, revogação e apagamento da conta.
- Origem + token CSRF assinado em mutações. O helper cliente renova tokens expirados. Webhooks usam assinatura do prestador, não sessão de navegador.
- Prisma parametrizado, locks consultivos e constraints PostgreSQL. Não se constroem instruções SQL a partir de texto de utilizador.
- Rate limits em login, recuperação, registo, holds, contactos, upload e operações sensíveis, com Redis ou fallback PostgreSQL.
- CSP com nonce, X-Content-Type-Options, Referrer-Policy, Permissions-Policy e HSTS/frame-ancestors no ambiente comercial.
- Autorizações servidor: cliente proprietária, profissional ativa e agenda associada, ou administração. Esconder um botão não é uma autorização.
- Uploads restritos a JPEG/PNG/WebP, limite de seis MB e de píxeis, reencodificação e remoção de metadados; não são aceites SVG/HTML enviados por operadores.
- A PWA nunca guarda APIs privadas ou dados de pagamento.

## Direitos e minimização

O perfil permite corrigir dados e consentimento promocional, descarregar a exportação JSON e pedir o apagamento com palavra-passe. A exportação não contém hashes de palavras-passe ou tokens de acesso.

A eliminação bloqueia contas com visitas futuras ou reembolsos em curso. Remove tokens, preferências, avaliações e correspondência identificável, incluindo mensagens de contacto dirigidas ao atelier; anonimiza nome, contacto, morada, NIF, notas e email; revoga sessões. Históricos que não devem desaparecer em contexto financeiro permanecem associados a um identificador anonimizado.

Mensagens de contacto anónimas só são associadas à exportação/eliminação depois de confirmar a titularidade do email. Um número telefónico partilhado não permite apagar comunicações de outra conta.

Não recolha informação clínica no campo de observações. Não há pixels publicitários ou analítica de terceiros. Fotografias que identifiquem clientes requerem autorização específica e processo de retirada; remover uma imagem da galeria não substitui a eliminação no armazenamento quando esse direito for exercido.

Os prazos de conservação legais, base jurídica concreta, entidade RAL competente, contratos com subcontratantes e transferências internacionais precisam de aprovação do responsável/jurista. Os textos fornecidos são uma base de configuração, claramente assinalada enquanto não for validada. Não constituem uma declaração de conformidade jurídica integral.

## Rotação

- AUTH_SECRET: instale a nova chave como principal e mantenha a anterior em AUTH_SECRET_PREVIOUS durante uma janela controlada superior à sessão de uma hora. Retire depois a anterior. Para incidente, remova a anterior e revogue sessionVersion dos acessos afetados.
- Palavra-passe de operador: script de provisionamento com ADMIN_ROTATE=true; não imprime a palavra-passe e revoga sessões.
- Stripe/Resend/Twilio/Blob/Redis: crie uma nova credencial de privilégio mínimo, publique-a por ambiente, verifique os serviços e só depois revogue a anterior. Coordene a rotação do segredo de webhook com o fornecedor e acompanhe reentregas.
- CRON_SECRET: coordene o valor do chamador e servidor; verifique a execução logo após a rotação.

Nunca inclua `.env`, `.env.test`, `credentials.local.md`, dumps, traces autenticados ou exports de clientes num commit ou pacote de publicação. Em caso de exposição, revogue primeiro; apagar um ficheiro não remove cópias nem o histórico Git.

## Limites conhecidos

Sem credenciais externas, os testes de prestadores são fixtures isoladas, não uma auditoria PCI ou validação de entregabilidade. Auth.js usado está no ramo v5; versões estão fixadas no lockfile e devem ser atualizadas com regressão de autenticação. A validação automatizada de acessibilidade complementa, mas não substitui, ensaios com teclado, leitores de ecrã e dispositivos reais.

## Isolamento adicional

A remoção/troca de uma conta profissional revoga o acesso anterior; alterações editoriais não o fazem desnecessariamente. A titularidade da agenda é novamente verificada antes de concluir/cancelar um atendimento. A listagem de clientes de uma profissional não inclui contagens de atendimentos realizados por outras profissionais.

O carregador de recursos limpa a exposição da conta anterior no próprio render e ignora respostas de pedidos abortados. Os testes de integração têm um preloader que exige `lumiere_test`/`DEPLOYMENT_ENV=test` e esvazia credenciais externas e Redis, impedindo que o fallback dotenv do Prisma as importe do ambiente local. O servidor de ensaios usa porta e base separadas e identifica visualmente os dados como cenários técnicos.
