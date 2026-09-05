# Preferências de marcação entre dispositivos

Um rascunho **não é uma marcação**, não ocupa um horário e não é confirmado ao recuperar a ligação.

O registo local contém apenas a escolha do cuidado, profissional, dia, instante de gravação e metadata de sincronização: identificador da versão, revisão de base e identificador pseudónimo da conta. Não contém nome, contacto, notas pessoais, palavra-passe nem token de sessão.

## Protocolo

A API de preferências responde com `{ ownerId, revision, draft }`. Cada alteração exige `ownerId`, `expectedRevision` e um `draftId` novo. O backend valida a conta autenticada, o cuidado e a profissional, e atualiza sob lock da cliente.

- Duas alterações baseadas na mesma revisão não se sobrepõem: a segunda recebe conflito.
- A repetição do mesmo identificador com o mesmo conteúdo é idempotente.
- Apagar conserva uma revisão sem conteúdo (*tombstone*), impedindo que uma escrita antiga ressuscite a preferência.
- Os relógios de telemóveis não decidem qual escolha prevalece. A data local só serve para limitar a retenção do rascunho.
- Em conflito, a interface conserva o rascunho local e pede uma escolha entre dispositivo e conta.
- Uma mudança de conta invalida pedidos pendentes e impede que a resposta da conta anterior seja gravada na nova sessão. O backend também confere a identidade, mesmo se o cookie tiver mudado durante a chamada.
- Uma preferência mais recente guardada noutro dispositivo não é apagada quando termina uma marcação baseada numa versão antiga.

As APIs e os recursos privados são associados à identidade no próprio render, não apenas num efeito posterior. Terminar a sessão elimina o rascunho local através da interface; expirar uma sessão não confirma nem transforma preferências em reservas.

## Atualização da PWA

A revisão substitui o protocolo de gravação anterior. Uma PWA antiga poderá continuar a guardar uma escolha local, mas terá de ser atualizada para a sincronizar. A recusa de um pedido antigo não cria nem cancela marcações. Use a notificação de atualização e volte a consultar a disponibilidade.
