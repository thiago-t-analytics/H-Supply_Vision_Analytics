// ─── ANIMAÇÃO DOS NÚMEROS ───
function animarNumero(el) {
    const alvo = parseInt(el.dataset.target, 10);
    const duracao = 2000; // 2 segundos
    const inicio = performance.now();

    function step(agora) {
        const progresso = Math.min((agora - inicio) / duracao, 1);
        // Easing out
        const eased = 1 - Math.pow(1 - progresso, 3);
        const valor = Math.floor(alvo * eased);
        el.textContent = valor.toLocaleString('pt-BR');
        if (progresso < 1) requestAnimationFrame(step);
        else el.textContent = alvo.toLocaleString('pt-BR');
    }
    requestAnimationFrame(step);
}

// Dispara quando a página carrega
window.addEventListener('load', () => {
    document.querySelectorAll('.stat-number').forEach((el, i) => {
        setTimeout(() => animarNumero(el), 300 + i * 200);
    });
});

// ─── PARTÍCULAS FLUTUANTES (sutil) ───
const canvas = document.createElement('canvas');
canvas.style.cssText = 'position:fixed;inset:0;pointer-events:none;z-index:2;opacity:0.35;';
document.body.appendChild(canvas);

const ctx = canvas.getContext('2d');
let particulas = [];

function redimensionar() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
}

function criarParticulas() {
    particulas = [];
    const qtd = Math.min(50, Math.floor(window.innerWidth / 30));
    for (let i = 0; i < qtd; i++) {
        particulas.push({
            x: Math.random() * canvas.width,
            y: Math.random() * canvas.height,
            r: Math.random() * 2 + 0.5,
            vx: (Math.random() - 0.5) * 0.3,
            vy: (Math.random() - 0.5) * 0.3,
            alpha: Math.random() * 0.5 + 0.2,
        });
    }
}

function animarParticulas() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particulas.forEach(p => {
        p.x += p.vx;
        p.y += p.vy;
        if (p.x < 0 || p.x > canvas.width)  p.vx *= -1;
        if (p.y < 0 || p.y > canvas.height) p.vy *= -1;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(129, 199, 132, ${p.alpha})`;
        ctx.fill();
    });
    requestAnimationFrame(animarParticulas);
}

window.addEventListener('resize', () => {
    redimensionar();
    criarParticulas();
});

redimensionar();
criarParticulas();
animarParticulas();