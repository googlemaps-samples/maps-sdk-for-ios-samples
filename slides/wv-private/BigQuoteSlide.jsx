import '../../tokens/colors.css';
import '../../tokens/typography.css';
import './wv-private.css';
import logo from '../../assets/logos/wv-private-mark.svg';

export default function BigQuoteSlide() {
  return (
    <main className="wv-slide wv-big-quote-slide">
      <img className="wv-logo" src={logo} alt="WV Private" />
      <blockquote>
        <span>“</span>
        Private navigation is not just a faster route; it is a calmer promise kept in real time.
      </blockquote>
      <p className="wv-attribution">WV Private blueprint principle</p>
    </main>
  );
}
