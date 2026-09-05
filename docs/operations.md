# Guia de operação

## Preparar a abertura

1. Entre em `/gestao` como administração. Ajuste identidade/contactos e valide a informação legal fora da aplicação.
2. Crie as profissionais com biografias reais e retratos autorizados. Para acesso interno, associe uma conta com email previamente confirmado. Deixar o email vazio desliga o acesso, sem apagar a agenda.
3. Em Horário do atelier, configure a abertura habitual e as exceções/feriados. Depois, em Disponibilidade, configure a semana, pausa, folgas e intervalo de cada profissional. Adicione férias/formação. Bloqueios sobre visitas existentes são recusados.
4. Em Carta de cuidados, configure descrições, materiais, técnica, preço final, duração e tempos de preparação/finalização; associe profissionais habilitadas.
5. Escolha a política de sinal: por cuidado, fixo global ou percentual. Sem Stripe/webhook, mantenha sinais a zero ou não disponibilize cuidados que os exijam.
6. Substitua imagens de inspiração por conteúdo autorizado. A galeria exige crédito e confirmação de direitos; trabalhos do atelier têm de ter profissional atribuída.
7. Configure os serviços externos e execute a lista de aceitação em ambiente isolado.

## No dia a dia

- A agenda distingue confirmação, pagamento pendente, realização, falta e cancelamento. Pode exportar os registos do período em CSV protegido contra fórmulas de folha de cálculo.
- Registe Realizado apenas quando o atendimento aconteceu, depois da hora de início. O ponto de fidelidade é atribuído atomicamente.
- Faltas não somam pontos. Cancelamentos iniciados pelo atelier devolvem um sinal recebido mesmo fora do prazo da cliente.
- A cliente reagenda na própria confirmação; a operação mantém preço, duração e janela de cancelamento aceites. A aplicação não move visitas antigas quando se altera o catálogo/horário de trabalho.
- As profissionais consultam apenas a sua agenda/clientes. Desativar uma profissional também impede acesso às operações de agenda.
- Não aprove avaliações inventadas. Só existem avaliações provenientes de visitas realizadas e o texto não pode ser fabricado no painel.

## Comunicação e pagamentos pendentes

O worker ou cron deve estar sempre ativo. A fila mostra o estado real e permite repetir mensagens BLOCKED/FAILED. Configure o prestador antes de repetir. DELIVERY_UNCERTAIN exige consulta do SMS no prestador, para evitar duplicação.

Em caso de reembolso pendente/fracassado, consulte o registo da marcação e o painel Stripe. Não registe dinheiro devolvido apenas porque houve um clique. `REFUNDED` é derivado da resposta/atualização do prestador. Não elimine pagamentos para libertar horários: a agenda e o reembolso são estados distintos.

SENT significa aceitação pelo prestador. Resend/Twilio podem ainda reportar rejeições/entregas no respetivo painel; essa entregabilidade final não é simulada pela aplicação.

## Modo offline e atualização

O catálogo, galeria e imagens previamente preparadas continuam a poder ser consultados. É possível guardar uma preferência. Para dados pessoais, disponibilidade, bloqueios e confirmações, volte a estar online e autenticada. Nunca trate um rascunho como reserva.

Uma versão nova pede atualização. Termine primeiro os formulários em curso: o recarregamento não confirma um hold. Um hold válido pode ser retomado na área de marcação, sem prolongar a expiração.

## Pré-visualização em iframe

Se o navegador impedir cookies de autenticação num iframe de outro domínio, abra a pré-visualização numa nova aba. Não enfraqueça os cookies de produção para contornar políticas do navegador. A instalação PWA também depende do navegador/dispositivo e aparece apenas quando suportada.

## Novas verificações no dia a dia

- Em **Sinais & devoluções**, reconcilie com o prestador antes de repetir uma devolução. Não existe um botão para marcar sinais como recebidos manualmente; veja `payments.md`.
- Se surgirem duas preferências de marcação, a cliente escolhe qual manter. O sistema não usa o relógio do dispositivo para substituir silenciosamente outra escolha; veja `booking-drafts.md`.
- Lembretes respeitam as preferências no momento do envio. Uma mensagem dirigida a um contacto entretanto alterado é cancelada, em vez de enviar dados para o destinatário anterior. Verifique os contactos nos próximos atendimentos.

## Antes do primeiro atendimento

Consulte **Preparar a abertura**. Credenciais presentes são identificadas como configuração, não como testes concluídos. Reveja a data e o âmbito das evidências e acompanhe o pulso real de worker/cron.

Alterar um horário com reservas aceites exige confirmação de impacto. Não utilize essa confirmação como substituto de contactar clientes ou processar cancelamentos/reembolsos quando aplicável. As marcações mantêm-se válidas até serem tratadas pelo seu próprio fluxo. Ver `opening-calendar.md` e `readiness.md`.
