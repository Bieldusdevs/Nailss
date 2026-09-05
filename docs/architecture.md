# Arquitetura e invariantes

## Domínios

- `client`: credenciais, sessões, perfil, preferências, consentimentos e direitos RGPD.
- `catalog`: coleção pública, pesquisa, páginas de serviço e portfólio.
- `booking`: calendário, regras temporais, bloqueios, confirmação e ciclo de vida.
- `artist`: equipa pública, especialidades e avaliações verificadas.
- `loyalty`: saldo, histórico, níveis e benefícios.
- `payment`: política do sinal, checkout, webhook e reembolsos.
- `communication`: outbox persistente, adaptadores, manutenção e gestão de reenvios.
- `administration`: operação de agenda, cuidados, profissionais, clientes e configurações.

`src/app` mantém páginas e adaptadores HTTP. `src/core` reúne apresentação transversal, segurança, acesso a recursos, observabilidade e infraestrutura. Componentes e regras específicas permanecem no respetivo domínio. Não há estado global de negócio que substitua a base de dados.

## Agenda concorrente

O intervalo ocupado é `[startsAt, occupiedUntil)`. A duração do cuidado é distinta da ocupação, que inclui preparação, finalização e intervalo da profissional. A agenda respeita janelas de trabalho, almoço, folgas e bloqueios.

A criação de um hold usa transação Serializable, locks consultivos parametrizados cliente→profissional e retry limitado para conflitos de serialização. Uma constraint de exclusão GiST é a última linha de defesa para HOLD, AWAITING_PAYMENT e CONFIRMED. Holds expirados são libertados antes de uma nova ocupação e pelo worker.

A transferência de uma marcação adquire o lock da cliente e os locks das profissionais por ordem estável. Só expira o hold novo dentro da transação que move a visita antiga. Falhar não cancela a visita original. Holds de reagendamento têm uma referência própria e não podem ser convertidos numa segunda visita com o preço antigo.

A API pública de disponibilidade não divulga dados de clientes. SSE publica revisões de agenda, com leitura aproximadamente a cada três segundos e reconexão; o cliente também atualiza a cada 20 segundos quando visível. Não use `networkidle` como condição de prontidão nos testes desta página.

## Pagamento

A política do sinal é aplicada ao catálogo e novamente pelo servidor na criação do bloqueio. O checkout conserva todo o payload antes de chamar Stripe, incluindo expiração, métodos e URL de retorno. Retentativas reutilizam payload e chave idempotente.

Um pagamento só confirma uma visita ainda AWAITING_PAYMENT e não expirada. O webhook verifica assinatura, checkout associado, moeda e montante. Eventos duplicados são detetados dentro dos locks. Pagamento tardio→REFUND_PENDING, nunca reocupação. Reembolsos têm chave idempotente própria e estado persistente.

`payment/types/deposit-gateway.ts` documenta a fronteira para outros gateways. **IfthenPay/SIBS não têm adaptador executável incluído**: exigem contrato, documentação e implementação certificada do respetivo fornecedor. Não aparecem como método disponível no frontend.

## Outbox

Confirmação, lembretes de 24h/2h, recuperação de acesso e contactos são persistidos com chave de deduplicação. O worker usa claim condicional e lease, retentativa limitada e orçamento temporal por ciclo. Ausência de credenciais→BLOCKED. SENT significa aceitação pelo prestador, não prova de leitura ou entrega final.

Em SMS de resultado ambíguo, a aplicação não repete automaticamente: marca DELIVERY_UNCERTAIN e exige confirmação do operador antes de reencaminhar. A mesma precaução aplica-se a leases SMS abandonados. Lembretes são revalidados contra o estado e a data atuais da visita.

## PWA

Cache-first para assets públicos; network-first para navegação pública e catálogo/equipa. As restantes APIs são network-only. Respostas de sessão, perfil, agenda privada, pagamento, holds e confirmações não são guardadas. Os rascunhos incluem serviço, profissional, dia e data de gravação; a sincronização autenticada atualiza apenas BookingPreference.

A instalação prepara páginas públicas, catálogo e respetivos chunks. A cache é versionada pelo BUILD_ID. Uma atualização fica à espera de confirmação da pessoa, em vez de interromper um formulário. O fallback privado offline não mostra dados pessoais.

## Atualização de integridade operacional

A gestão de acessos de profissionais é serializada; mudar uma associação revoga as sessões necessárias e devolve o acesso anterior à role de cliente, sem retirar administração a quem já a tinha. Editar a biografia não revoga sessões. Contas associadas exigem email verificado.

Os recursos privados no React são chaveados pela identidade; respostas abortadas ou de uma conta anterior não podem aparecer num novo render. As preferências usam revisão otimista e tombstones, descritos em `booking-drafts.md`.

As animações editoriais pertencem a `AtelierPageMotion`, dentro da árvore hidratada de cada página. A coordenação global conserva apenas movimento e elementos próprios; não altera antecipadamente nós de páginas ainda em hidratação.

A agenda administrativa calcula os limites dos dias no fuso de Lisboa, incluindo dias de 23/25 horas. Os lembretes revalidam preferências, estado da visita e destinatário antes do envio. Dados estruturados de avaliações só são produzidos para opiniões aprovadas de atendimentos realizados, com identificação comercial validada e agregados reais. Isto não garante apresentação de estrelas em motores de pesquisa.

## Calendário central e evidência operacional

A abertura do atelier é persistida em AtelierOpeningPlan/AtelierOpeningException. A disponibilidade cruza esta definição com os turnos das profissionais. Edições usam uma revisão e um lock exclusivo; os escritores de ocupação adquirem primeiro leitura partilhada da abertura. O impacto sobre reservas aceites exige confirmação ligada à revisão e conjunto afetado.

AtelierJobPulse regista execução real do worker/cron. IntegrationObservation regista apenas eventos com âmbito específico, depois de validar assinatura ou resposta do prestador, e liga-os ao ambiente/configuração. A consulta de prontidão não executa transações externas.
