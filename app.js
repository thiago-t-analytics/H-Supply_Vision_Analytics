
const SUPABASE_URL = 'https://qggfxneiwatooytmkrnb.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnZ2Z4bmVpd2F0b295dG1rcm5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4NTQ2NTcsImV4cCI6MjEwNjQzMDY1N30.P97t9CnMNEv9FKg8TmcIa8qgIk3fFqJkRKPpVcnFkPM';

// ✅ MUDANÇA: nome do cliente é 'sb' em vez de 'supabase'
//    (a variável global 'supabase' é da biblioteca CDN)
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    db: { schema: 'gold' }
});

const statusEl = document.getElementById('status');
const tbody = document.querySelector('#contagens tbody');
const listaPacientes = document.getElementById('lista-pacientes');

async function testarConexao() {
    try {
        // 1. Testa conexão básica
        const { data, error } = await sb
            .from('dim_cid')
            .select('*')
            .limit(1);

        if (error) throw error;

        statusEl.textContent = '✓ Conectado ao Supabase (schema gold)';
        statusEl.className = 'ok';

        // 2. Conta registros
        const tabelas = ['dim_cid', 'dim_item', 'dim_paciente', 'fato_dispensacao'];
        for (const t of tabelas) {
            const { count } = await sb
                .from(t)
                .select('*', { count: 'exact', head: true });
            const tr = document.createElement('tr');
            tr.innerHTML = `<td>${t}</td><td>${count ?? '—'}</td>`;
            tbody.appendChild(tr);
        }

// 3. Busca 10 pacientes
        const { data: pacientes, error: errP } = await sb
            .from('dim_paciente')
            .select('*')
            .limit(10);

        if (errP) throw errP;

        if (pacientes && pacientes.length) {
            const colunas = Object.keys(pacientes[0]);
            const liHeader = document.createElement('li');
            liHeader.style.fontWeight = 'bold';
            liHeader.textContent = `Colunas: ${colunas.join(', ')}`;
            listaPacientes.appendChild(liHeader);

            pacientes.slice(0, 10).forEach(p => {
                const li = document.createElement('li');
                const valores = colunas.slice(0, 3).map(c => p[c]).join(' | ');
                li.textContent = valores;
                listaPacientes.appendChild(li);
            });
        }

    } catch (err) {
        console.error('Erro detalhado:', err);
        statusEl.textContent = `✗ Erro: ${err.message}`;
        statusEl.className = 'erro';
    }
}

testarConexao();