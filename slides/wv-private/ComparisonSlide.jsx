import '../../tokens/colors.css';
import '../../tokens/typography.css';
import './wv-private.css';
import logo from '../../assets/logos/wv-private-mark.svg';

const columns = [
  { title: 'Standard mapping', items: ['Broad consumer context', 'Generic ETA language', 'Reactive support moments'] },
  { title: 'WV Private layer', items: ['Member-aware privacy controls', 'Confidence bands and exception cues', 'Proactive concierge handoffs'] },
];

export default function ComparisonSlide() {
  return (
    <main className="wv-slide wv-comparison-slide">
      <img className="wv-logo" src={logo} alt="WV Private" />
      <p className="wv-eyebrow">Service difference</p>
      <h1>Make every route feel intentionally managed.</h1>
      <section className="wv-columns">
        {columns.map((column) => (
          <article className="wv-column" key={column.title}>
            <h2>{column.title}</h2>
            <ul>{column.items.map((item) => <li key={item}>{item}</li>)}</ul>
          </article>
        ))}
      </section>
    </main>
  );
}
