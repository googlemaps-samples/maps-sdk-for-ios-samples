import '../../tokens/colors.css';
import '../../tokens/typography.css';
import './wv-private.css';
import logo from '../../assets/logos/wv-private-mark.svg';

export default function SectionDividerSlide() {
  return (
    <main className="wv-slide wv-section-divider">
      <img className="wv-logo" src={logo} alt="WV Private" />
      <p className="wv-kicker">02 / Operating model</p>
      <h1>From location signal to concierge certainty</h1>
      <div className="wv-divider-line" />
    </main>
  );
}
