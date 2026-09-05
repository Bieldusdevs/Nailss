# Horário central, exceções e reservas aceites

## Onde gerir

Em **Gestão → Horário do atelier**, a administração define:

- Horário habitual por dia da semana, com até quatro intervalos por dia.
- Encerramentos por data, incluindo feriados.
- Aberturas especiais com intervalos próprios e uma indicação pública.

O horário inicial corresponde aos dados fornecidos: segunda a sexta, 10h–20h; sábado, 09h–18h; domingo encerrado. A migração cria esta configuração; a seed não substitui configurações nem repõe turnos apagados de profissionais existentes.

Uma exceção substitui apenas o horário do atelier nessa data. **Não atribui turnos à equipa.** A disponibilidade é a interseção de horário central, turno da profissional, preparação/finalização/intervalo, bloqueios e ocupações existentes. Os inícios são alinhados a quartos de hora e a ocupação completa tem de terminar antes do fecho real.

No formulário, 00:00 no fecho significa a meia-noite no fim desse dia. Encerrar um dia é diferente de abrir das 00:00 à meia-noite seguinte. A agenda usa Europe/Lisbon, incluindo mudanças sazonais; horas inexistentes não são oferecidas.

## Proteção de compromissos existentes

Uma alteração não cancela nem reagenda visitas automaticamente. Se colocar novos compromissos já aceites fora do horário publicado, o servidor devolve uma confirmação de impacto com contagem e referências. A administração tem de reconhecer que essas reservas serão respeitadas ou tratadas individualmente com as clientes.

A confirmação é ligada à pessoa, revisão, alteração e conjunto de reservas afetadas. Um novo bloqueio ou outra alteração pode invalidá-la e exigir nova confirmação. Confirmar um hold já contemplado na confirmação de impacto não altera a sua duração, preço ou direitos.

Bloqueios válidos existentes podem ser retomados até à expiração original, mesmo depois de o horário ter sido alterado com reconhecimento do impacto. Novos bloqueios não podem entrar no intervalo encerrado. Expiração, cancelamento e reagendamento continuam a seguir as regras próprias.

## Concorrência e persistência

`AtelierOpeningPlan` guarda a revisão e a semana. `AtelierOpeningException` guarda datas, intervalos e indicação pública. Mutações exigem uma revisão esperada; uma versão antiga não substitui alterações de outra pessoa.

A ordem é abertura (leitura partilhada) → cliente → profissional. Mudanças de horário usam um lock exclusivo de abertura. A leitura `FOR SHARE` da configuração faz uma transação Serializable detetar uma revisão alterada enquanto aguardava o lock; o scheduler repete conflitos de serialização de forma limitada.

Depois de guardar, a revisão de agenda é publicada por SSE. Contactos, rodapé e dados estruturados usam a mesma configuração. A cópia pública contém um dia de referência, evitando recalcular exceções durante a hidratação de uma página guardada offline.

O diagnóstico de abertura também identifica compromissos futuros que continuam fora do horário público, para acompanhamento humano. A indicação pública de uma exceção não deve incluir nomes, informação clínica ou motivos pessoais.
