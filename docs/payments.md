# Sinais, devoluções e reconciliação

A área **Gestão → Sinais & devoluções** consulta os pagamentos persistidos, pesquisa por referência/cliente e distingue montantes recebidos, devolvidos e ainda por receber. É reservada à administração; profissionais não acedem a valores de outras clientes.

Não existe uma ação para marcar um pagamento como recebido manualmente. **Consultar o estado na Stripe** lê o checkout e as devoluções do prestador e volta a aplicar as mesmas validações de moeda, montante, intenção e titularidade. Sem credenciais, a ação está desativada e não produz valores de demonstração.

## Histórico de reembolsos

`DepositRefund` guarda cada referência de reembolso individual, o montante, o estado observado e a origem do pedido. Só referências efetivamente concluídas somam `refundedCents`. Repetir um evento não duplica montantes e um evento antigo não faz uma devolução concluída regredir.

O vínculo à intenção de pagamento permite registar um webhook que chegue antes de o worker ter recebido a resposta ao pedido. Reembolsos feitos no painel do prestador também são identificados na reconciliação. A migração não inventa datas: mantém apenas o montante de reembolsos completos já registados pela versão anterior.

## Tentativas e incerteza

- O montante de cada tentativa é fixado antes da chamada. Repetições usam o mesmo montante, metadata e chave idempotente.
- Erros de rede preservam a tentativa; não originam uma nova chave automaticamente.
- Depois de 23 horas sem desfecho confirmado, o pedido é assinalado `STRIPE_OUTCOME_UNKNOWN`, antes de se arriscar ultrapassar a retenção da chave no prestador. É necessária verificação humana.
- A ação **Retomar reembolso previsto na política** só aparece para obrigações já existentes e estados elegíveis. Volta a consultar o prestador e recusa um montante entretanto alterado, outra devolução em curso ou um resultado desconhecido.
- Cancelar durante uma devolução externa em curso não perde o direito ao saldo restante. Se a devolução externa falhar ou for parcial, a administração pode reconciliar e retomar a obrigação aplicável, sem tratar valores pendentes como já devolvidos.

O worker também consulta periodicamente operações em processamento e pagamentos conhecidos, dentro de um orçamento temporal. O painel mostra a data da última observação; não promete um saldo em tempo real quando o prestador está indisponível.

## Limites de aceitação

Os testes automatizados incluem respostas de API explicitamente isoladas. Não provam habilitação comercial de MB WAY/Multibanco, entregabilidade ou aceitação de um reembolso pela conta do comerciante. Antes do lançamento, realize esses ensaios com as credenciais e o ambiente Stripe apropriados.

Esta área trata sinais online, não caixa do atelier, emissão de faturas certificadas ou contabilidade fiscal. Nunca confunda o valor dos atendimentos com recebimentos de caixa.
