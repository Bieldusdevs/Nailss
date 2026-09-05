# Preparar a abertura: configuração não é teste

**Gestão → Preparar a abertura** é reservado à administração. A consulta não cria pagamentos nem envia mensagens de teste. Também não publica o site ou declara conformidade comercial.

## Estados apresentados

| Estado | Significado |
|---|---|
| Verificado agora | Uma verificação local foi realmente executada: por exemplo, SELECT em PostgreSQL, PING de Redis ou leitura da configuração. |
| Evidência observada | O sistema guardou um evento com o âmbito e data indicados. Não é uma garantia mais ampla. |
| Configurado | Existe configuração, mas falta evidência correspondente a este ambiente/credenciais. |
| Declarado | O responsável registou uma declaração, como a validação legal. Não é uma certificação automática. |
| Requer ação / Indisponível | Há uma pendência ou a verificação não foi possível. |
| Opcional | A integração não é necessária para a configuração atual, por exemplo Stripe com todos os sinais a zero. |

As contagens são derivadas dos próprios checks, não uma percentagem fictícia de aprovação. Pode continuar a explorar e configurar o ambiente local com pendências; isso não o transforma num ambiente comercial aprovado.

## Evidências externas com âmbito limitado

- **Stripe:** um webhook com assinatura validada foi recebido. Não comprova habilitação de MB WAY/Multibanco, aceitação de todos os cartões ou um reembolso real.
- **Email/SMS:** o prestador aceitou uma submissão com um identificador de resposta. Não comprova entrega, leitura, reputação do remetente ou consentimento jurídico adequado.

As evidências ficam ligadas ao ambiente e a um fingerprint secreto da configuração. Mudanças de credenciais, remetente, ambiente ou configuração relevante deixam a evidência anterior sem correspondência. O fingerprint e as credenciais **não são devolvidos ao navegador**. Falhar a gravação desta observabilidade não repete um pagamento nem transforma um envio aceite em nova tentativa.

A assinatura do webhook é testada antes de registar a evidência; um pedido com assinatura inválida não a cria. Testes isolados e respostas simuladas de prestadores, quando usados no desenvolvimento, não são apresentados como verificações comerciais.

## Execução do worker/cron

`AtelierJobPulse` guarda início, conclusão, duração e código não sensível da última rotina. Uma execução antiga não pode sobrescrever uma mais recente. Um processo que deixou de terminar gera uma pendência; não existe um indicador sempre verde por haver simplesmente um comando de worker configurado.

O estado OK da rotina não implica envio de todas as mensagens. Credenciais ausentes podem manter mensagens BLOCKED, e entregabilidade continua a ser verificada no fornecedor.

## Verificações humanas continuam necessárias

Confirmar dados e identificação fiscal, entidade RAL, textos legais, conservação/RGPD, licenças de imagem, configuração de domínio/HTTPS, backups restauráveis e ensaios com contas comerciais. A existência de um catálogo, de uma conta administrativa ou de credenciais não substitui estas verificações.
