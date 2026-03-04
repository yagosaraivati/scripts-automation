param(
    [Parameter(Mandatory=$false)]
    [string]$Usuario
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Import-Module ActiveDirectory

try {

    if (-not $Usuario) {
        $Usuario = Read-Host "Login do usuario?"
    }

    $user = Get-ADUser -Identity $Usuario -Server "DOMINIO_AQUI" -Properties `
        MemberOf,
        AccountExpirationDate,
        Enabled,
        PasswordNeverExpires,
        CannotChangePassword,
        PasswordLastSet,
        LockedOut -ErrorAction Stop

    Write-Host "`n::::::::::::::::::: DADOS DO USUARIO :::::::::::::::::::" -ForegroundColor Yellow
    Write-Host "`n" -ForegroundColor DarkGray
    Write-Host "Nome: $($user.Name)"
    Write-Host "Login: $($user.SamAccountName)"
    Write-Host "Conta habilitada: $($user.Enabled)"
    Write-Host "Conta bloqueada: $($user.LockedOut)"

    if ($user.AccountExpirationDate) {
        Write-Host "Vencimento da conta: $($user.AccountExpirationDate)"
    } else {
        Write-Host "Vencimento da conta: Nao expira"
    }

    Write-Host "`n::::::::::::::::::: OPCOES DA CONTA DO USUARIO $Usuario :::::::::::::::::::" -ForegroundColor Yellow
    Write-Host "`n" -ForegroundColor DarkGray
    Write-Host "Senha nunca expira: $($user.PasswordNeverExpires)"
    Write-Host "Usuario nao pode alterar senha: $($user.CannotChangePassword)"
    Write-Host "Ultima alteracao de senha: $($user.PasswordLastSet)"

    Write-Host "`n::::::::::::::::::: MEMBRO DOS GRUPOS :::::::::::::::::::" -ForegroundColor Yellow
    Write-Host "`n" -ForegroundColor DarkGray
    if ($user.MemberOf.Count -gt 0) {
        $user.MemberOf | ForEach-Object {
            (Get-ADGroup $_).Name
        } | Sort-Object | ForEach-Object {
            Write-Host "- $_"
        }
    } else {
        Write-Host "Usuario nao pertence a nenhum grupo."
    }

}
catch {
    Write-Host "`nErro ao consultar o usuario." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
}

Write-Host "`n" -ForegroundColor DarkGray
Write-Host "::::::: Compartilhando solucao simples :::::::" -ForegroundColor Cyan
Write-Host "`n" -ForegroundColor DarkGray

Read-Host "Pressione ENTER para sair"
