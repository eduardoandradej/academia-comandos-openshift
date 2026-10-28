# Preparação de storage (Trilha 09)

> **REQUER PREPARAÇÃO** — o HomeLab foi instalado com **0 StorageClasses e 0 PVs**, e a quota da Academia proíbe
> PVCs (`persistentvolumeclaims: 0`). Este roteiro libera os exercícios STO-008 a STO-015 da
> [Trilha 09](../trilhas/09-storage/README.md). A Academia **não** executa nada disto sozinha: cada etapa é uma decisão
> do administrador do HomeLab, tomada uma vez e com autorização.

## O que funciona sem preparação

STO-001 a STO-007 e STO-014 (falhas 1 e 2): `emptyDir`, `emptyDir` em memória, armazenamento efêmero e despejo,
inventário de storage (somente leitura), anatomia de PVC com `--dry-run`, diagnóstico. Os cenários TS-028 a TS-030
também não exigem preparação.

## Escolha uma opção

| | Opção A — NFS + PVs estáticos | Opção B — LVM Storage (LVMS) |
|---|---|---|
| Onde ficam os dados | HD do `kvm-server` (`/mnt/hd1tb`), fora do SSD | disco virtual extra no SNO |
| Mudança no cluster | 3 PVs (objetos de cluster rotulados) | operador novo em `openshift-storage` + StorageClass |
| Mudança em hosts | servidor NFS e firewall no `kvm-server` | disco anexado à VM `ocp-sno` |
| Provisionamento | estático (`storageClassName: ac09-nfs`) | dinâmico (`lvms-vg1`) |
| Expansão (STO-012) | não | sim |
| `ReadWriteOncePod` (STO-011) | não | sim |
| `ReadWriteMany` | sim | não |
| Desfazer | simples | desinstalar o operador e liberar o disco |
| Recomendação | **comece por aqui** | quando quiser praticar storage dinâmico |

`hostPath` e PVs `local` no próprio nó **não** são opções: exigem mexer no sistema de arquivos do único nó (SSD) e
SCCs mais permissivas.

## Opção A — NFS no kvm-server com PVs estáticos

### A.1 Servidor NFS (no `kvm-server`, como root, com autorização)

```bash
ip -4 -br addr                                   # anote o IP do kvm-server na rede 192.168.10.0/24
df -h /mnt/hd1tb                                 # o HD precisa estar montado
dnf install -y nfs-utils
mkdir -p /mnt/hd1tb/ac09-nfs/pv01 /mnt/hd1tb/ac09-nfs/pv02 /mnt/hd1tb/ac09-nfs/pv03
chown -R nobody:nobody /mnt/hd1tb/ac09-nfs
chmod 0777 /mnt/hd1tb/ac09-nfs/pv0*              # o UID do pod é arbitrário; all_squash grava como nobody
cat > /etc/exports.d/ac09.exports <<'EOT'
/mnt/hd1tb/ac09-nfs 192.168.10.200(rw,sync,all_squash,anonuid=65534,anongid=65534,no_subtree_check)
EOT
systemctl enable --now nfs-server
exportfs -rav
firewall-cmd --permanent --add-service=nfs && firewall-cmd --reload
```

Notas:

- a exportação vale **só** para o IP do SNO (`192.168.10.200`);
- confirme se o SELinux do RHCOS permite NFS para contêineres (`getsebool virt_use_nfs` via `oc debug node`, somente
  leitura); o padrão costuma ser `on`;
- se o firewall do `kvm-server` tiver zonas por interface, aplique a regra na zona da rede `192.168.10.0/24`.

### A.2 PVs e quota (na `ocp-admin`, perfil `admin`)

```bash
source scripts/perfis.sh && ac-admin
IP=<IP do kvm-server em 192.168.10.0/24>
sed "s/NFS_SERVER/$IP/" manifests/preparacao/storage-nfs-pv.yaml | oc apply --dry-run=server -f -
sed "s/NFS_SERVER/$IP/" manifests/preparacao/storage-nfs-pv.yaml | oc apply -f -
oc get pv -l academy.openshift.dev/managed-by=academia            # 3 x Available
oc get project ac09-storage -o name     # criado pelo developer no STO-002; se faltar, crie-o como developer antes
oc apply --dry-run=server -f manifests/preparacao/quota-storage-ac09.yaml -n ac09-storage
oc apply -f manifests/preparacao/quota-storage-ac09.yaml -n ac09-storage
oc describe quota ac-quota -n ac09-storage | grep -E 'persistentvolumeclaims|requests.storage'
ac-dev
export SC=ac09-nfs
```

Teste rápido (developer): crie o PVC do [STO-008](../trilhas/09-storage/exercicios/STO-008.md) e confira `Bound`.

### A.3 Desfazer a opção A

```bash
# admin, depois de apagar o projeto ac09-storage
oc delete pv -l academy.openshift.dev/managed-by=academia
# kvm-server, root
rm -f /etc/exports.d/ac09.exports && exportfs -rav
firewall-cmd --permanent --remove-service=nfs && firewall-cmd --reload
rm -rf /mnt/hd1tb/ac09-nfs
```

## Opção B — LVM Storage (provisionamento dinâmico)

LVMS é o armazenamento local indicado pela Red Hat para SNO. Visão geral (siga a documentação oficial da versão 4.22
para os detalhes):

1. **Disco** — no `kvm-server`, com o SNO em funcionamento, crie um disco QCOW2 pequeno (por exemplo, 10 GiB),
   **de preferência no HD**, e anexe-o à VM `ocp-sno` (`virsh attach-disk ... --persistent`). Confira o espaço
   livre antes: a regra de manter > 20 GiB livres em `/var` continua valendo.
2. **Operador** — como admin, instale o *LVM Storage* pelo OperatorHub no namespace `openshift-storage`.
   É uma mudança de cluster: faça com autorização e anote a versão instalada.
3. **LVMCluster** — crie um `LVMCluster` apontando **explicitamente** para o disco novo (`deviceSelector.paths`),
   nunca para o disco do sistema.
4. **Classe** — confira `oc get storageclass` (esperado `lvms-vg1`, com `allowVolumeExpansion: true`).
5. **Quota** — aplique `manifests/preparacao/quota-storage-ac09.yaml` no `ac09-storage`, como na opção A.
6. Na `ocp-admin`: `export SC=lvms-vg1`.

Atenção: se o LVMS marcar a classe como **padrão** do cluster, PVCs sem `storageClassName` em qualquer projeto
passarão a provisionar disco. Avalie remover a anotação de classe padrão se não quiser esse efeito.

Desfazer: apagar PVCs → apagar o `LVMCluster` → desinstalar o operador → desanexar o disco. Siga a ordem.

## Conferência final

```bash
source scripts/perfis.sh && ac-dev
echo "SC=$SC"
oc get resourcequota -n ac09-storage -o jsonpath='{.items[0].spec.hard.persistentvolumeclaims}{"\n"}'   # 3
scripts/preflight.sh
```
