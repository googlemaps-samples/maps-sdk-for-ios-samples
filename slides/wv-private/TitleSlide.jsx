import '../../tokens/colors.css';
import '../../tokens/typography.css';
import './wv-private.css';
import logo from '../../assets/logos/wv-private-mark.svg';

export default function TitleSlide() {
  return (
    <main className="wv-slide wv-title-slide">
      <img className="wv-logo" src={logo} alt="WV Private" />
      <section className="wv-title-copy">
        <p className="wv-eyebrow">Private mobility intelligence</p>
        <h1>Blue routes for high-trust experiences</h1>
        <p className="wv-subtitle">A concise system for secure journeys, premium service, and location confidence.</p>
      </section>
      <div className="wv-map-card" aria-hidden="true">
        <span className="wv-route" />
        <span className="wv-pin wv-pin-a" />
        <span className="wv-pin wv-pin-b" />
      </div>
    </main>
  );
}
