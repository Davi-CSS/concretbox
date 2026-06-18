<template>
  <div id="concretbox">
    <nav>
      <span class="logo">ConcretBox</span>
      <div class="links">
        <router-link to="/">Lançar</router-link>
        <router-link to="/historico">Histórico</router-link>
      </div>
    </nav>

    <main>
      <router-view />
    </main>
  </div>
</template>

<style>
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: system-ui, sans-serif;
  background: #f5f5f4;
  color: #1c1c1a;
  min-height: 100vh;
}

nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1.5rem;
  height: 56px;
  background: #fff;
  border-bottom: 1px solid #e5e3dc;
}

.logo {
  font-size: 16px;
  font-weight: 600;
  letter-spacing: -0.3px;
  color: #1c1c1a;
}

.links {
  display: flex;
  gap: 1.5rem;
}

.links a {
  font-size: 14px;
  color: #6b6b67;
  text-decoration: none;
  padding: 4px 0;
  border-bottom: 2px solid transparent;
  transition: color 0.15s, border-color 0.15s;
}

.links a.router-link-active {
  color: #1c1c1a;
  border-color: #1c1c1a;
}

main {
  max-width: 760px;
  margin: 0 auto;
  padding: 2rem 1.5rem;
}
</style>
