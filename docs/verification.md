# Verificação da versão entregue

## Resultado executado

| Verificação | Resultado |
|---|---|
| TypeScript estrito e verificação de tipos do Next | Aprovado |
| Compilação otimizada `npm run build` | Aprovada; cache PWA marcada com o BUILD_ID |
| Regras e segurança unitárias | **36 testes aprovados** |
| Integração com PostgreSQL isolado | **43 testes aprovados** |
| Percursos Playwright/Chromium | **13 testes aprovados** |
| Axe na página inicial, tags WCAG 2 A/AA e 2.1 A/AA | **0 violações detetadas neste ensaio** |
| `npm audit`, incluindo dependências de desenvolvimento | **0 vulnerabilidades reportadas** |
| `/api/health` na pré-visualização | HTTP 200, `{"status":"ok"}` |

**Total: 92 testes automáticos aprovados.** Os resultados de auditoria dizem respeito às versões fixadas no lockfile e ao momento da execução; não são uma garantia futura ou certificação de conformidade integral.

## Percursos de navegador efetivamente exercitados

1. Página inicial, catálogo, marcação, contactos, clube e galeria a 390×844, menu móvel funcional e ausência de transbordamento horizontal.
2. Registo por formulário, autenticação real, cinco etapas, criação de hold no servidor, confirmação sem sinal e download de calendário ICS.
3. Reagendamento preservando a marcação original, cancelamento, gravação de dados pessoais, exportação sem hash de palavra-passe e apagamento autenticado.
4. Recusa de acesso de cliente à API administrativa; entrada de administrador, criação de cuidado arquivado persistido na base e edição visual da disponibilidade em ecrã móvel.
5. Service worker em produção, catálogo e galeria offline, fallback seguro para perfil, gravação de rascunho e inspeção das caches para garantir ausência de APIs privadas.

Nesta atualização, os ensaios de navegador correram numa instância separada, com a base `lumiere_test`, prestadores externos desativados e indicação visual de dados de teste. A pré-visualização principal foi verificada sem clientes de QA, pagamentos ou avaliações inventados. A instância de testes foi encerrada após os ensaios.

6. Acesso de uma profissional apenas à sua agenda/clientes e recusa de acesso ao painel financeiro e visitas de outra profissional.
7. Consulta de um sinal parcialmente devolvido, cálculo do saldo e recusa de alterações manuais de estado de pagamento.
8. Conflito entre preferências de dois dispositivos, resolução explícita e ausência de reservas criadas pela sincronização.
9. Revogação de sessões e mudança de conta sem exposição dos pontos ou preferências da conta anterior.
10. Navegação imediata durante a hidratação inicial, sem erros React provocados pelas animações.

11. Encerramento por data com reservas existentes: confirmação de impacto obrigatória, reservas mantidas e novas tentativas recusadas.
12. Horário semanal refletido nos contactos e no rodapé, com restauração da configuração de teste.
13. Painel de prontidão com verificações locais, pendências externas e recusa de acesso profissional, sem credenciais/fingerprints na resposta.

## Concorrência e regras verificadas em PostgreSQL

- Duas clientes disputam o mesmo slot: apenas uma consegue o hold.
- A repetição do mesmo hold mantém a expiração original.
- Inserir uma visita em conflito diretamente pela camada de dados falha pela constraint de exclusão.
- Confirmação repetida não duplica correspondência.
- Reagendamento conserva preço/duração após edição do catálogo; hold expirado não altera a visita original.
- Um sinal pendente impede novos bloqueios.
- Eventos Stripe duplicados são consumidos uma única vez; pagamento tardio não recupera um slot já adquirido por outra cliente.
- Conclusões concorrentes não duplicam pontos; dois resgates não gastam o mesmo saldo.
- Tokens reais de verificação/recuperação são descartáveis e a redefinição revoga sessões.
- Prestadores ausentes nunca produzem mensagens SENT.
- Associação, transferência e remoção de acesso profissional revogam apenas as sessões necessárias; a edição da biografia não o faz.
- Duas associações concorrentes não ligam uma conta a duas agendas.
- Escritas de rascunho usam a revisão esperada; apagar não permite ressuscitar versões antigas.
- Lembretes são cancelados quando a preferência ou o destinatário já não correspondem.
- Devoluções parciais, eventos repetidos ou fora de ordem e webhooks anteriores à resposta do worker não duplicam nem fazem regredir montantes.
- Pedidos de reembolso preservam chave e valor; um resultado desconhecido não autoriza outra tentativa com nova chave.
- Cancelar durante uma devolução externa preserva a obrigação relativa ao saldo restante.
- Os limites da agenda administrativa respeitam dias de 23/25 horas na mudança de hora em Lisboa.

Os eventos de pagamento usados nesta camada são fixtures explícitas de teste numa base `lumiere_test`, **não pagamentos reais nem validação de uma conta Stripe**.

## Abertura e prontidão verificadas nesta atualização

- O horário central cruza com os turnos e pausas da equipa; exceções substituem a semana só na data indicada.
- Bloqueios respeitam o período completo, incluindo buffers. Horas inexistentes na mudança sazonal não são oferecidas.
- Mudar ou retirar uma exceção com reservas aceites exige confirmação de impacto. Uma nova reserva invalida uma confirmação desatualizada.
- Um encerramento e um novo bloqueio concorrentes não criam uma ocupação invisível. A leitura Serializable deteta uma revisão alterada enquanto esperava pelo lock.
- Credenciais presentes são distintas de evidência observada. Alterar a configuração ou o ambiente invalida a correspondência da evidência.
- Só uma assinatura de webhook válida regista evidência de receção. O ensaio usa uma assinatura local de teste, não um pagamento comercial.
- O pulso regista execução/conclusão real e não deixa uma rotina antiga sobrescrever outra mais recente; erros não incluem texto sensível.
- O teste de Redis aguarda a ligação inicial de forma limitada e confirma um PING real, sem confundir uma ligação ainda em arranque com uma prova de disponibilidade.

## Ajustes realizados durante a verificação

As animações editoriais passaram a ser executadas apenas na árvore hidratada da respetiva página. Foram também reforçados o isolamento de recursos por conta, a sincronização por revisão e a consulta de reembolsos no prestador.

Foram corrigidos o preenchimento do contacto ao reagendar, a coordenação de scroll entre Lenis e as etapas, o overflow do horário semanal em ecrãs pequenos, atributos ARIA e contrastes. A leitura de configurações em operações de reserva é estrita, sem fallback silencioso para regras de sinal. A validação de redes sociais aceita campos vazios e rejeita protocolos executáveis sem exceções fora de Zod.

## O que permanece dependente do responsável

- Credenciais, conta comercial e teste real de Stripe/MB WAY/Multibanco e reembolsos.
- Entregabilidade de Resend/Twilio, remetentes autorizados e reconciliação no fornecedor.
- Ensaios de instalação/atualização em iOS e Android físicos, leitor de ecrã e testes de carga/restauro.
- Licenças e autorizações completas das imagens de inspiração ou substituição por fotografias próprias.
- Validação dos dados de exemplo, textos legais, RAL, retenção e contratos RGPD.
- Publicação num repositório/conta Vercel do titular. Não foi efetuado deploy comercial externo.

Consulte `testing.md` para reproduzir e ampliar os ensaios. As capturas da execução estão na pasta de QA do workspace, fora do pacote público e sem funcionar como conteúdo de clientes.
